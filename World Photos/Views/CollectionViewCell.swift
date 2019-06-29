import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        activityIndicator.startAnimating()
    }
    
    func addImage(data: Data?, delay: Double) {
        guard data != nil else {return}
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.activityIndicator.stopAnimating()
            self.imageView.image = UIImage(data: data!)
        }
    }
    
    
    
    
}
