//
//  MNCollectionViewLayout.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/11.
//

import UIKit
import LSExtensions

protocol MNCollectionViewLayoutDelegate : NSObjectProtocol{
    func collectionViewLayout(viewLayout: MNCollectionViewLayout, didChangeCollectionViewHeight height: CGFloat);
}

class MNCollectionViewLayout: UICollectionViewFlowLayout {
    
    @IBInspectable
    var maxColumns : Int = 2{
        didSet{
            
        }
    }
    
    @IBInspectable
    var maxRows: Int = 0{
        didSet{
            
        }
    }
    
    @IBInspectable
    var glimpseVertical: CGFloat = 0.0{
        didSet{
            
        }
    }
    
    @IBInspectable
    var glimpseHorizontal: CGFloat = 0.0{
        didSet{
            
        }
    }
    
    @IBInspectable
    var ratio: Float = .nan{
        didSet{
            
        }
    }
    
    var ratioInsets : UIEdgeInsets = UIEdgeInsets.zero{
        didSet{
            
        }
    }
    
    @IBInspectable
    var topRatioInsets : CGFloat{
        get{
            return self.ratioInsets.top;
        }
        set(value){
            self.ratioInsets.top = value;
        }
    }
    
    @IBInspectable
    var bottomRatioInsets : CGFloat{
        get{
            return self.ratioInsets.bottom;
        }
        set(value){
            self.ratioInsets.bottom = value;
        }
    }
    
    @IBInspectable
    var leftRatioInsets : CGFloat{
        get{
            return self.ratioInsets.left;
        }
        set(value){
            self.ratioInsets.left = value;
        }
    }
    
    @IBInspectable
    var rightRatioInsets : CGFloat{
        get{
            return self.ratioInsets.right;
        }
        set(value){
            self.ratioInsets.right = value;
        }
    }
    
    @IBInspectable
    var fitHeight : Bool = false{
        didSet{
            
        }
    }
    
    weak var delegate : MNCollectionViewLayoutDelegate?;
    weak var tableView : UITableView?;
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.maxColumns = 2;
        self.maxRows = 0;
    }
    
    override func prepare() {
        super.prepare();
        
        guard let collectionView = self.collectionView, self.maxColumns > 0 || self.maxRows > 0 else{
            return;
        }
        
        var collectionFrame = collectionView.frame;
        let collectionInsets = collectionView.contentInset;
        if let tableView = self.tableView, let tableCell = collectionView.parent(type: UITableViewCell.self){
            collectionFrame.size.width = collectionFrame.width.advanced(by: tableCell.realWidthOffset(tableView));
//            debugPrint("[\(#function)] fixes collection width. tableCell[\(tableCell.frame)] tableView[\(tableView.frame)] collection[\(collectionFrame.size)]");
            
        }
        
        let maxColumns = CGFloat(self.maxColumns) + self.glimpseHorizontal;
        let spaceColumn = self.minimumLineSpacing * CGFloat(max(0, self.maxColumns - 1));
        var outColumnsSpacing = self.sectionInset.left + self.sectionInset.right;
        if #available(iOS 11.0, *) {
            outColumnsSpacing += collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right;
        }
        
        let maxRows = CGFloat(self.maxRows) + self.glimpseVertical;
        let spaceRow = self.minimumInteritemSpacing * CGFloat(max(0, self.maxRows - 1));
        var outRowsSpacing = self.sectionInset.top + self.sectionInset.bottom;
        if #available(iOS 11.0, *) {
            outRowsSpacing += collectionView.safeAreaInsets.top + collectionView.safeAreaInsets.bottom;
        }
        
        var cellWidth : CGFloat = maxColumns > 0 ? (collectionFrame.width - spaceColumn - outColumnsSpacing - collectionInsets.left) / maxColumns : self.itemSize.width;
        var cellHeight : CGFloat = maxRows > 0 ? (collectionFrame.height - spaceRow - outRowsSpacing - collectionInsets.top) / maxRows : self.itemSize.height;
        //Change another side to fit ratio
        if maxColumns > 0, !self.ratio.isNaN{
            cellHeight = cellWidth * CGFloat(self.ratio) + (self.ratioInsets.bottom + self.ratioInsets.top);
        }else if maxRows > 0, !self.ratio.isNaN{
            cellWidth = cellHeight / CGFloat(self.ratio) + (self.ratioInsets.left + self.ratioInsets.right);
        }
        
        self.itemSize = CGSize.init(width: cellWidth, height: cellHeight);
        
//        debugPrint("new collection item size[\(self.itemSize)] maxColumns[\(self.maxColumns)] maxRows[\(self.maxRows)] spaceColumn[\(spaceColumn)] spaceRow[\(spaceRow)] collectionViewSize[\(collectionView.bounds.size)]");
    }
    
    override func invalidateLayout() {
        super.invalidateLayout();
        
        self.fitLayoutHeight();
    }
    
    func fitLayoutHeight(){
        guard let collectionView = self.collectionView, self.maxColumns > 0 || self.maxRows > 0 else{
            return;
        }
        
        let collectionFrame = collectionView.frame;
        
        let enoughHeight = CGFloat(self.itemSize.height) + sectionInset.top + sectionInset.bottom - collectionView.contentInset.top - collectionView.contentInset.bottom; //self.ratioInsets.bottom + self.ratioInsets.top;
        if collectionFrame.size.height < enoughHeight || self.fitHeight{
            let constraints = collectionView.constraints.first(where: { (c) -> Bool in
                var value = false;
                guard collectionView.isEqual(c.firstItem) else{
                    return false;
                }
                
                if #available(iOS 10.0, *), c.firstAnchor == collectionView.heightAnchor {
                    value = true;
                }else if c.firstAttribute == .height{
                    value = true;
                }
                
                return value;
            });
            
            var heightChanged = false;
            if let heightConstraint = constraints{
//                debugPrint("[\(#function)] update collection view height with constraint. enough[\(enoughHeight)] collection[\(collectionView.height)] constraint[\(heightConstraint.description)] item[\(self.itemSize)] sectionInset[\(sectionInset)] contentInset[\(collectionView.contentInset)] ratioInsets[\(self.ratioInsets)]")
                heightChanged = heightConstraint.constant != enoughHeight;
                heightConstraint.constant = heightConstraint.constant != collectionView.height ? collectionView.height : enoughHeight;
                //collectionView.layoutIfNeeded();
            }else{
//                debugPrint("[\(#function)] update collection view height without constraint. item[\(self.itemSize)] height[\(enoughHeight)]")
                heightChanged = collectionFrame.size.height != enoughHeight;
                collectionView.frame.size.height = enoughHeight;
                collectionView.layoutIfNeeded();
            }
            
            if heightChanged{
                self.delegate?.collectionViewLayout(viewLayout: self, didChangeCollectionViewHeight: enoughHeight);
            }
        }
    }
}

// MARK: Set max columns/rows from collection view
extension UICollectionView{
    var siwonLayout : MNCollectionViewLayout?{
        return self.collectionViewLayout as? MNCollectionViewLayout;
    }
    
    var maxColumns : Int?{
        get{
            return (self.collectionViewLayout as? MNCollectionViewLayout)?.maxColumns;
        }
        set(value){
            (self.collectionViewLayout as? MNCollectionViewLayout)?.maxColumns = value ?? 0;
        }
    }
    
    var maxRows : Int?{
        get{
            return (self.collectionViewLayout as? MNCollectionViewLayout)?.maxRows;
        }
        set(value){
            (self.collectionViewLayout as? MNCollectionViewLayout)?.maxRows = value ?? 0;
        }
    }
}

extension UICollectionView{
    var dynamicCollectionViewLayout : MNCollectionViewLayout?{
        return self.collectionViewLayout as? MNCollectionViewLayout;
    }
}
