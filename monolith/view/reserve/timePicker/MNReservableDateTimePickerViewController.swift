//
//  MNDateTimePickerViewController.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/09.
//

import UIKit
import RxSwift
import RxCocoa
import RxCollectionExtensions
import RxDataSources

class MNReservableDateTimePickerViewController: UIViewController {

    var ticket: Int?{
        didSet{
            self.loadDays();
        }
    }
    
    class Cells{
        static let day = "day";
        static let time = "time";
        static let product = "product";
    }
    
    var product : Observable<String?>{
        return self.viewModel.product;
    }
    
    var time : Observable<MNReservableTimeInfo?>{
        return self.viewModel.selectedTime;
    }
    
    var times : [MNReservableTimeInfo]{
        return (try? self.viewModel.times.value()) ?? [];
    }
    
    var timeDataSource = RxCollectionViewSectionedReloadDataSource<MNReservableTimeGroupInfo>.init { (dataSource, collectionView, indexPath, item) -> UICollectionViewCell in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.time, for: indexPath) as? MNReservableTimeCollectionViewCell;
        cell?.info = item;
        return cell!;
    } configureSupplementaryView: { (dataSource, collectionView, kind, indexPath) -> UICollectionReusableView in
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Cells.product, for: indexPath) as? MNReserableTimeHeaderView;
        header?.product = dataSource.sectionModels[indexPath.item].title;
        
        return header!;
    }

    
    @IBOutlet weak var daysView: UICollectionView!
    @IBOutlet weak var timesView: UICollectionView!
    
    lazy var timeEmptyView: MNEmptyView = MNEmptyView.init(message: "예약 가능한 시간이 없습니다 😢", fontSize: 40);
    
    var viewModel: MNReservableTimePickerViewModel = .init();
    private var disposeBag: DisposeBag = .init();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupBindings();
        
        self.timesView.backgroundView = self.timeEmptyView;
        //self.loadDays();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        debugPrint(#function);
        self.timesView.layoutIfNeeded();
        self.timesView.reloadData();
        self.timesView.collectionViewLayout.invalidateLayout();
    }
    
    func setupBindings(){
        let days = self.viewModel.days
            .materialize().share();
        
        let times = self.viewModel.times
            .materialize().share();
        
        days.compactMap{ $0.element }
            .observe(on: MainScheduler.asyncInstance)
            .do(afterNext: { [weak self](days) in
                guard days.any else{
                    return;
                }
                
                self?.daysView.selectItem(at: IndexPath.init(item: 0, section: 0), animated: false, scrollPosition: .left); //select today automatically
                DispatchQueue.main.async {
                    self?.updateMonthLabels();
                }
            })
            .bind(toCollectionView: self.daysView,
                  cellIdentifier: Cells.day,
                  cellType: MNReservableDayCollectionViewCell.self,
                  disposeBag: self.disposeBag) { (index, row, cell) in
                cell.info = row;
            }
        
        self.daysView.rx.modelSelected(MNReservableDayInfo.self)
//            .distinctUntilChanged(at: \.date)
            .bind(to: self.viewModel.selectedDay)
            .disposed(by: self.disposeBag);
        
        self.daysView.rx.contentOffset
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self](_) in
                debugPrint(#function);
                self?.updateMonthLabels();
            }.disposed(by: self.disposeBag);
        
        Observable.combineLatest(self.product.compactMap{ $0 }, times.compactMap{ $0.element })
            .map{ [MNReservableTimeGroupInfo.init(title: $0.0, items: $0.1)] }
            .bind(to: self.timesView.rx.items(dataSource: self.timeDataSource))
            .disposed(by: self.disposeBag);
//        times.compactMap{ $0.element }
//            .bind(toCollectionView: self.timesView,
//                  cellIdentifier: Cells.time,
//                  cellType: MNReservableTimeCollectionViewCell.self,
//                  disposeBag: self.disposeBag) { (index, row, cell) in
//                cell.info = row;
//            }
        
        times
            .map{ $0.element?.any ?? false }
            .bind(to: self.timeEmptyView.rx.isHidden)
            .disposed(by: self.disposeBag);
        
        self.timesView.rx.modelSelected(MNReservableTimeInfo.self)
//            .distinctUntilChanged(at: \.date)
            .do{ debugPrint("time select. time[\($0)]") }
            .bind(to: self.viewModel.selectedTime)
            .disposed(by: self.disposeBag);
        
        self.timesView.rx.setDelegate(self)
            .disposed(by: self.disposeBag);
        
        self.viewModel.nextOnConfirm
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext:{ [weak self](msg, completion) in
                self?.showAlert(title: "시간선택 확인", msg: msg, actions: [.default("시간결정", handler: { (act) in
                    completion(true);
                }), .cancel("취소", handler: { (act) in
                    completion(false);
                })], style: .alert);
            }).disposed(by: self.disposeBag);
        
//        self.viewModel.isCurrentStep
//            .observe(on: MainScheduler.asyncInstance)
//            .bind { [weak self](value) in
//                guard value else {
//                    return;
//                }
//
//                self?.timesView.setNeedsLayout();
//            }.disposed(by: self.disposeBag);
    }
    
    func loadDays(){
        guard let ticket = self.ticket else{
            return;
        }
        
        self.viewModel.loadDays(ticketId: ticket);
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: Calendar
extension MNReservableDateTimePickerViewController{
    func updateMonthLabels(){
        let cells = (self.daysView.visibleCells as? [MNReservableDayCollectionViewCell])?
            .sorted(by: { $0.info!.date < $1.info!.date })
        var isFirst = true;
        cells?.forEach({ (cell) in
            guard let info = cell.info else{
                return;
            }
            
            cell.isMonthVisible = info.date.day == 1 || isFirst;
//            if cell.isMonthVisible{
//                debugPrint(info.date, "day[\(info.date.day)] first[\(isFirst)]")
//            }
            isFirst = false;
        })
    }
}

extension MNReservableDateTimePickerViewController : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let values = self.times;
        
        guard values.any else{
            return false;
        }
        
        return values[indexPath.item].isEnabled;
    }
    
//    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
//        debugPrint("---------------------------------------");
//    }
}

extension MNReservableDateTimePickerViewController: MNStepPage{
    var stepConfirmed : Observable<Bool>{
        return self.viewModel.confirmed;
    }
    
    func confirmStep(){
        self.viewModel.confirm();
    }
    
    func isOwner(ForViewModel viewModel: NSObject) -> Bool {
        return self.viewModel === viewModel;
    }
}
