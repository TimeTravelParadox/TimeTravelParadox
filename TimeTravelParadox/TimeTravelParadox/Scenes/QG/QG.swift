import SpriteKit

class QG: SKNode{
  let past = SKScene(fileNamed: "QGScene")
  let hud = HUD()
  
  var QGBG: SKSpriteNode?
  
  let QGST = SKAction.repeatForever(SKAction.playSoundFileNamed("QGST.mp3", waitForCompletion: true))
  
    
  override init(){
    super.init()
    if let past {
      QGBG = (past.childNode(withName: "QGBG") as? SKSpriteNode)
      QGBG?.removeFromParent()
      
      self.isUserInteractionEnabled = true
    }
    if let QGBG{
      self.addChild(QGBG)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
  
}
