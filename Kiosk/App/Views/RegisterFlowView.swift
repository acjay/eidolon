import UIKit
import ORStackView
import ReactiveCocoa

class RegisterFlowView: ORStackView {

    dynamic var highlightedIndex = 0
    let jumpToIndexSignal = RACSubject()

    lazy var appSetup: AppSetup = .sharedState

    var details: BidDetails? {
        didSet {
            self.update()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .whiteColor()
        self.bottomMarginHeight = CGFloat(NSNotFound)
        self.updateConstraints()
    }

    private struct SubViewParams {
        let title: String
        let keypath: Array<String>
    }

    private lazy var subViewParams: Array<SubViewParams> = {
        return [
            [SubViewParams(title: "Mobile", keypath: ["phoneNumber"])],
            [SubViewParams(title: "Email", keypath: ["email"])],
            [SubViewParams(title: "Postal/Zip", keypath: ["zipCode"])].filter { _ in self.appSetup.needsZipCode }, // TODO: may remove, in which case no need to flatten the array
            [SubViewParams(title: "Credit Card", keypath: ["creditCardName", "creditCardType"])]
        ].flatMap {$0}
    }()

    func update() {
        let user = details!.newUser

        removeAllSubviews()
        for (i, subViewParam) in subViewParams.enumerate() {
            let itemView = ItemView(frame: self.bounds)
            itemView.createTitleViewWithTitle(subViewParam.title)

            addSubview(itemView, withTopMargin: "10", sideMargin: "0")

            if let value = (subViewParam.keypath.flatMap { user.valueForKey($0) as? String }.first) {
                itemView.createInfoLabel(value)

                let button = itemView.createJumpToButtonAtIndex(i)
                button.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)

                itemView.constrainHeight("44")
            } else {
                itemView.constrainHeight("20")
            }

            if i == highlightedIndex {
                itemView.highlight()
            }
        }

        let spacer = UIView(frame: bounds)
        spacer.setContentHuggingPriority(12, forAxis: .Horizontal)
        addSubview(spacer, withTopMargin: "0", sideMargin: "0")

        self.bottomMarginHeight = 0
    }

    func pressed(sender: UIButton!) {
        jumpToIndexSignal.sendNext(sender.tag)
    }

    class ItemView : UIView {

        var titleLabel: UILabel?

        func highlight() {
            titleLabel?.textColor = .artsyPurple()
        }

        func createTitleViewWithTitle(title: String)  {
            let label = UILabel(frame:self.bounds)
            label.font = UIFont.sansSerifFontWithSize(16)
            label.text = title.uppercaseString
            titleLabel = label

            self.addSubview(label)
            label.constrainWidthToView(self, predicate: "0")
            label.alignLeadingEdgeWithView(self, predicate: "0")
            label.alignTopEdgeWithView(self, predicate: "0")
        }

        func createInfoLabel(info: String) {
            let label = UILabel(frame:self.bounds)
            label.font = UIFont.serifFontWithSize(16)
            label.text = info

            self.addSubview(label)
            label.constrainWidthToView(self, predicate: "-52")
            label.alignLeadingEdgeWithView(self, predicate: "0")
            label.constrainTopSpaceToView(titleLabel!, predicate: "8")
        }

        func createJumpToButtonAtIndex(index: NSInteger) -> UIButton {
            let button = UIButton(type: .Custom)
            button.tag = index
            button.setImage(UIImage(named: "edit_button"), forState: .Normal)
            button.userInteractionEnabled = true
            button.enabled = true

            self.addSubview(button)
            button.alignTopEdgeWithView(self, predicate: "0")
            button.alignTrailingEdgeWithView(self, predicate: "0")
            button.constrainWidth("36")
            button.constrainHeight("36")
            
            return button

        }
    }
}
