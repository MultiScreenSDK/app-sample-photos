
import UIKit

class MyFlowLayout : UICollectionViewFlowLayout {
    // how to left-justify every "line" of the layout
    // looks much nicer, in my humble opinion
    
    
    var numOFColumn = [Int]()
    var itemSizeLarge : Int!
    var itemSizeSmall : Int!
    
    override func prepareLayout() {
        super.prepareLayout()
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        itemSizeLarge = Int(screenSize.width / 2)
        itemSizeSmall = Int(screenSize.width / 4)
        
        
        numOFColumn = [0,itemSizeSmall,itemSizeLarge,itemSizeSmall * 3]
        
        //itemSize = CGSizeMake(self.collectionView!.bounds.width, 99)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        
      
        let arr = super.layoutAttributesForElementsInRect(rect) as [UICollectionViewLayoutAttributes]
        
        println("Number of items in rect : \(arr.count)")
        
        return arr.map {
            atts in
            if atts.representedElementKind == nil {
                let ip = atts.indexPath
                atts.frame = self.layoutAttributesForItemAtIndexPath(ip).frame
            }
            return atts
        }
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        let atts = super.layoutAttributesForItemAtIndexPath(indexPath)
        
        var modIndexRow = indexPath.row % 10
        var originX = 0
        var originY = 0
        var width = 0
        
        originY = indexPath.row / 5;
        
        switch (modIndexRow) {
        case 0:
            originX = numOFColumn[0];
            originY = originY * itemSizeLarge;
            width = itemSizeLarge
            break;
        case 1:
            originX = numOFColumn[2];
            originY = originY * itemSizeLarge;
            width = itemSizeSmall
            break;
        case 2:
            originX = numOFColumn[3];
            originY = originY * itemSizeLarge;
            width = itemSizeSmall
            break;
        case 3:
            originX = numOFColumn[2];
            originY = (originY * itemSizeLarge) + itemSizeSmall;
            width = itemSizeSmall
            break;
        case 4:
            originX = numOFColumn[3];
            originY = (originY * itemSizeLarge) + itemSizeSmall;
            width = itemSizeSmall
            break;
        case 5:
            originX = numOFColumn[0];
            originY = (originY * itemSizeLarge);
            width = itemSizeSmall
            break;
        case 6:
            originX = numOFColumn[1];
            originY = (originY * itemSizeLarge);
            width = itemSizeSmall
            break;
        case 7:
            originX = numOFColumn[2];
            originY = (originY * itemSizeLarge);
            width = itemSizeLarge
            break;
        case 8:
            originX = numOFColumn[0];
            originY = (originY * itemSizeLarge)+itemSizeSmall;
            width = itemSizeSmall
            break;
        case 9:
            originX = numOFColumn[1];
            originY = (originY * itemSizeLarge)+itemSizeSmall;
            width = itemSizeSmall
            break;
        default: break;
        }
        
        //let ipPv = NSIndexPath(forItem:indexPath.item-1, inSection:indexPath.section)
        //let fPv = self.layoutAttributesForItemAtIndexPath(ipPv).frame
        //let rightPv = fPv.origin.x + fPv.size.width + self.minimumInteritemSpacing
        atts.frame.origin.x = CGFloat(originX)
        atts.frame.origin.y = CGFloat(originY)
        atts.frame.size.width = CGFloat(width)
        atts.frame.size.height = CGFloat(width)
        
        return atts
    }

}
