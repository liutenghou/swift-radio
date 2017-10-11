//
//  ViewController.swift
//  RadyoTurkiye
//
//  Created by İkbal Yaşar on 29.11.2016.
//  Copyright © 2016 ikbal. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer



class ViewController: UIViewController ,  UITableViewDataSource , UITableViewDelegate , UISearchBarDelegate   {
    
    @IBOutlet weak var tableView: UITableView!
    var nowPlayingImageView: UIImageView!
    let DataBase = SQLiteDB.shared
    var RadyoDizisi = [RadyoClass()]
    var k = 1
    public let radioPlayer = MPMoviePlayerController()

    
    var tableViewItems = [AnyObject]()
  
    let adIntervar = 8
    let adViewHeight = CGFloat(135)
    let adViewWidth = CGFloat(370)
    
   
    
    @IBOutlet weak var searchBar: UISearchBar!
    var searchActive : Bool = false

    var filtered = [RadyoClass()]
    

    @IBOutlet weak var btnpausebaritem: UIButton!
    var t = 1
    @IBAction func btnpausebaritemClck(_ sender: Any) {
        if(t == 1){
   
            radioPlayer.stop()
            nowPlayingImageView.stopAnimating()
            btnpausebaritem.setImage(UIImage(named: "btn-play.png"), for: UIControlState.normal)
            t = 2
        }
        else
        {
            radioPlayer.play()
            btnpausebaritem.setImage(UIImage(named: "btn-pause.png"), for: UIControlState.normal)
            nowPlayingImageView.startAnimating()
            nowPlayingImageView.isHidden = false
            t = 1
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        DataBase.openDB()
  
        
    
        UIApplication.shared.isIdleTimerDisabled = true;
        
        
        createNowPlayingAnimation()
        searchBar.layer.borderColor = UIColor.clear.cgColor
       
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        var error: NSError?
        var success: Bool
        do {
            try AVAudioSession.sharedInstance().setCategory(
                AVAudioSessionCategoryPlayAndRecord,
                with: .defaultToSpeaker)
            success = true
        } catch let error1 as NSError {
            error = error1
            success = false
        }
        if !success {
            
        }
        searchBar.delegate = self
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        var Radyolar =  DataBase.query(sql: " select * from Radyolar order by Adi asc"   , parameters: nil)
        
        for i in 0 ..< Radyolar.count  {
            let Radyo = RadyoClass()
            Radyo.radyoAdi = Radyolar[i]["Adi"] as? String!
            Radyo.URL = Radyolar[i]["URL"] as? String!
            Radyo.favori = Radyolar[i]["Favori"] as? String!
            Radyo.resim = Radyolar[i]["Icon"] as? String!
            
            RadyoDizisi.append(Radyo)

            
        }
        
        
        RadyoDizisi.remove(at: 0)
        
        filtered = RadyoDizisi
        self.tableView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool)
    {
        searchBar.text = ""
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchBar.text == nil)
        {
            
            return filtered.count
            
        }
        else
        {
            return RadyoDizisi.count
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell" , for: indexPath) as! RadyoTableViewCell
        //
       
        if(searchBar.text == ""){
            cell.btnFavori.layer.shadowOffset = CGSize(width: 0, height: 1)
            // btnEzberOut.layer.shadowRadius = 1
            cell.btnFavori.layer.shadowOpacity = 0.5
            cell.btnFavori.contentEdgeInsets = UIEdgeInsetsMake(1,1,1,1)
            cell.iconview?.image = UIImage(named: RadyoDizisi[(indexPath as NSIndexPath).row].resim)
            // cell.textLabel?.text = filtered[indexPath.row]
            cell.lblRadyoAdi.text = filtered[(indexPath as NSIndexPath).row].radyoAdi
            let favoriicon = Int(filtered[(indexPath as NSIndexPath).row].favori!)
            _ = filtered[(indexPath as NSIndexPath).row].URL
            if(favoriicon == 1) {
                cell.btnFavori.setImage(UIImage(named:"favori1"), for: .normal)
                
            }
            else {
                cell.btnFavori.setImage(UIImage(named:"fav1"), for: .normal)
            }
            
            cell.btnFavori.tag = indexPath.row
            cell.btnFavori.addTarget(self, action: #selector(ViewController.btnfavoriyebas(sender:)), for: .touchUpInside)
            
            
        }
        else {
            
            cell.btnFavori.layer.shadowOffset = CGSize(width: 0, height: 1)
            cell.btnFavori.layer.shadowOpacity = 0.5
            cell.btnFavori.contentEdgeInsets = UIEdgeInsetsMake(1,1,1,1)
            
            cell.iconview?.image = UIImage(named: RadyoDizisi[(indexPath as NSIndexPath).row].resim)
            cell.lblRadyoAdi.text = RadyoDizisi[(indexPath as NSIndexPath).row].radyoAdi
            let favoriicon = Int(RadyoDizisi[(indexPath as NSIndexPath).row].favori!)
            _ = RadyoDizisi[(indexPath as NSIndexPath).row].URL
            if(favoriicon == 1) {
                cell.btnFavori.setImage(UIImage(named:"favori1"), for: .normal)
                
            }
            else {
                cell.btnFavori.setImage(UIImage(named:"fav1"), for: .normal)
            }
            
            cell.btnFavori.tag = indexPath.row
            cell.btnFavori.addTarget(self, action: #selector(ViewController.btnfavoriyebas(sender:)), for: .touchUpInside)
    
            
        }
 
        
        return cell
        
    }

    @objc func btnfavoriyebas(sender: UIButton){

        let buttonRow = sender.tag
        
        if( Int(RadyoDizisi[buttonRow].favori)! == 1)
        {
            RadyoDizisi[buttonRow].favori = "2"
            sender.setImage(UIImage(named:"fav1"), for: .normal)
            let sql1 = "update Radyolar set Favori = '\(2)' where URL = '\(RadyoDizisi[buttonRow].URL!)'"
            _ = self.DataBase.execute(sql: sql1)
            
            
            
        }
        else{
            
            
            RadyoDizisi[buttonRow].favori = "1"
            sender.setImage(UIImage(named:"favori1"), for: .normal)
            let sql2 = "update Radyolar set Favori = '\(1)' where URL = '\(RadyoDizisi[buttonRow].URL!)'"
            _ = self.DataBase.execute(sql: sql2)
            if (k == 2){
                RadyoDizisi.remove(at: buttonRow)
                filtered.remove(at: buttonRow)
                //                print(RadyoDizisi[buttonRow].radyoAdi)
                //                print(filtered[buttonRow].radyoAdi)
                
            }
            print(k)
        }
        
        self.tableView.reloadData()
        
        
    }
    
    
    
    var RadyoURL: String = ""
    
    // static let sharedInstance = RadioPlayer()
    fileprivate var isPlaying = false

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        
        nowPlayingImageView.startAnimating()
        nowPlayingImageView.isHidden = false
        btnpausebaritem.isHidden = false
        self.title = RadyoDizisi[(indexPath as NSIndexPath).row].radyoAdi
        radioPlayer.stop()
        radioPlayer.contentURL = URL(string: RadyoDizisi[(indexPath as NSIndexPath).row].URL)
        radioPlayer.prepareToPlay()
        radioPlayer.play()
        
        
        
        
        
        let image:UIImage = UIImage(named: RadyoDizisi[(indexPath as NSIndexPath).row].resim)!
        let albumArt = MPMediaItemArtwork(image: image)
        if NSClassFromString("MPNowPlayingInfoCenter") != nil {
            //            let image:UIImage = UIImage(named: "logo_player_background")!
            //            let albumArt = MPMediaItemArtwork(image: image)
            let songInfo = [
                MPMediaItemPropertyTitle: RadyoDizisi[(indexPath as NSIndexPath).row].radyoAdi,
                MPMediaItemPropertyArtist: RadyoDizisi[(indexPath as NSIndexPath).row].radyoAdi,
                MPMediaItemPropertyArtwork: albumArt
                ] as [String : Any]
            MPNowPlayingInfoCenter.default().nowPlayingInfo = songInfo
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            UIApplication.shared.beginReceivingRemoteControlEvents()
            print("Receiving remote control events\n")
        } catch {
            radioPlayer.pause()
            print("Audio Session error.\n")
        }
        
        
        
        
    }

    func playRadio() {
        radioPlayer.play()
    }
    
    func pauseRadio() {
        radioPlayer.stop()
        
    }
 
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        if(searchText.characters.count == 0){
            RadyoDizisi.removeAll()
            for i in 0 ..< filtered.count {
                
                RadyoDizisi.append(filtered[i])
                
                
            }
            
            searchBar.resignFirstResponder()
        }
        else{
            RadyoDizisi.removeAll()
            for i in 0 ..< filtered.count {
                
                if(filtered[i].radyoAdi?.lowercased().range(of: searchText.lowercased()) != nil || filtered[i].radyoAdi?.range(of: searchText.uppercased(with: (Locale(identifier: "tr")))) != nil)
                {
                    RadyoDizisi.append(filtered[i])
                }
                
                
                
            }
            
            
            
        }
        
        self.tableView.reloadData()
    }

    @IBAction func btnFavori(_ sender: Any) {
  
 
        if(k == 1){
            
            var Radyolar =  DataBase.query(sql: " select * from Radyolar where Favori = '2' order by Adi asc"   , parameters: nil)

            if(Radyolar.count != 0){
                RadyoDizisi.removeAll()
                for i in 0 ..< Radyolar.count  {
                    let Radyo = RadyoClass()
                    
                    Radyo.radyoAdi = Radyolar[i]["Adi"] as? String!
                    Radyo.URL = Radyolar[i]["URL"] as? String!
                    Radyo.favori = Radyolar[i]["Favori"] as? String!
                    Radyo.resim = Radyolar[i]["Icon"] as? String!
                    RadyoDizisi.append(Radyo)
                    
                }
                filtered = RadyoDizisi
                k = 2
            }
            else{
                let alertController = UIAlertController(title: "Üzgünüm :(", message: "Favori listene hiç Radyo eklememissin", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
                
                // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
                let okAction = UIAlertAction(title: "Tamam", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    print("OK")
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
        }
        else if ( k == 2 ){
            
            RadyoDizisi.removeAll()
            
            var Radyolar =  DataBase.query(sql: " select * from Radyolar order by Adi asc"   , parameters: nil)
            
            for i in 0 ..< Radyolar.count  {
                let Radyo = RadyoClass()
                
                Radyo.radyoAdi = Radyolar[i]["Adi"] as? String!
                Radyo.URL = Radyolar[i]["URL"] as? String!
                Radyo.favori = Radyolar[i]["Favori"] as? String!
                Radyo.resim = Radyolar[i]["Icon"] as? String!
                
                RadyoDizisi.append(Radyo)
                
                
            }
            filtered = RadyoDizisi
            k = 1
            
            
            
            
        }
        
        
        
        self.tableView.reloadData()
        
        
        
    }
    
    
    
    func createNowPlayingAnimation() {
        
        // Setup ImageView
        nowPlayingImageView = UIImageView(image: UIImage(named: "NowPlayingBars-3"))
        nowPlayingImageView.autoresizingMask = []
        nowPlayingImageView.contentMode = UIViewContentMode.center
        
        // Create Animation
        nowPlayingImageView.animationImages = AnimationFrames.createFrames()
        nowPlayingImageView.animationDuration = 0.7
        nowPlayingImageView.isHidden = true
        // Create Top BarButton
        let barButton = UIButton(type: UIButtonType.custom)
        barButton.frame = CGRect(x: 0,y: 0,width: 40,height: 40);
        barButton.addSubview(nowPlayingImageView)
        nowPlayingImageView.center = barButton.center
        
        let barItem = UIBarButtonItem(customView: barButton)
        
        self.navigationItem.leftBarButtonItem = barItem
        
    }
    
    
    
    
    
    
    
    
    
    
}


