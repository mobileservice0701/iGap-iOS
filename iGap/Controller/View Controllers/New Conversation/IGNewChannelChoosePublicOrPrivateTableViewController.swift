/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import UIKit
import RealmSwift
import IGProtoBuff

class IGNewChannelChoosePublicOrPrivateTableViewController: UITableViewController ,UITextFieldDelegate,SSRadioButtonControllerDelegate , UIGestureRecognizerDelegate {
    
    @IBOutlet weak var publicChannelButton: SSRadioButton!
    @IBOutlet weak var privateChannel: SSRadioButton!
    @IBOutlet weak var channelLinkTextField: UITextField!
    var radioButtonController: SSRadioButtonsController?
    @IBOutlet weak var privateChannelCell: UITableViewCell!
    @IBOutlet weak var publicChannelCell: UITableViewCell!
    @IBOutlet weak var channelNameEntryCell: UITableViewCell!
    var invitedLink: String?
    var igpRoom : IGPRoom!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        radioButtonController = SSRadioButtonsController(buttons: publicChannelButton, privateChannel)
        radioButtonController!.delegate = self
        radioButtonController!.shouldLetDeSelect = true
        channelLinkTextField.delegate = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        channelLinkTextField.isUserInteractionEnabled = false
        tableView.sectionIndexBackgroundColor = UIColor.white
        self.tableView.contentInset = UIEdgeInsetsMake(-1.0, 0, 0, 0)
        print(self.tableView.sectionHeaderHeight)
        privateChannelCell.selectionStyle = UITableViewCellSelectionStyle.none
        publicChannelCell.selectionStyle = UITableViewCellSelectionStyle.none
        //channelNameEntryCell.selectionStyle = UITableViewCellSelectionStyle.none
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "Next", title: "New Channel")
        navigationItem.navigationController = self.navigationController as! IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.hidesBackButton = true
        navigationItem.rightViewContainer?.addAction {
            self.performSegue(withIdentifier: "GoToChooseMemberFromContactPage", sender: self)
            
        }
        
    }
    
    func didSelectButton(_ aButton: UIButton?) {
        if radioButtonController?.selectedButton() == publicChannelButton {
            tableView.reloadData()
            channelLinkTextField.isUserInteractionEnabled = true
            channelLinkTextField.text = nil
            let channelDefualtName = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
            channelDefualtName.font = UIFont.systemFont(ofSize: 14)
            channelDefualtName.text = "iGap.net/"
            channelLinkTextField.leftView = channelDefualtName
            channelLinkTextField.leftViewMode = UITextFieldViewMode.always
            channelLinkTextField.placeholder = "yourlink"
            channelLinkTextField.delegate = self
        }
        if radioButtonController?.selectedButton() == privateChannel {
           channelLinkTextField.leftView = nil
           channelLinkTextField.text = invitedLink
           channelLinkTextField.isUserInteractionEnabled = false
           channelLinkTextField.delegate = self
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var numberOfRows : Int = 0
        switch section {
        case 0:
            numberOfRows = 2
        case 1:
            numberOfRows = 1
        default:
            break
        }
        return numberOfRows
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectButton(radioButtonController?.selectedButton())
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var footerText : String = ""
        if section == 1 {
        
        if radioButtonController?.selectedButton() == publicChannelButton {
            footerText = "People can share this link whith others and find your channel using iGap search."
        }
        if radioButtonController?.selectedButton() == privateChannel {
            footerText = "People can join your channel by following this link.you can change the link at any time."
          
        }
        
      }
        return footerText
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var headerText : String = ""
        if section == 0 {
            headerText = ""
            
        }
        if section == 1{
            headerText = "   "
        }
        return headerText
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var headerHieght : CGFloat = 0
        if section == 0 {
            headerHieght = CGFloat.leastNonzeroMagnitude
        }
        if section == 1 {
            headerHieght = 0
        }
        return headerHieght
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! IGChooseMemberFromContactToCreateChannelViewController
        destinationVC.igpRoom = igpRoom
        destinationVC.mode = "CreateChannel"
    }

}
