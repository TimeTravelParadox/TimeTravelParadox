import SpriteKit

class Hologram: SKNode {
  private let future = SKScene(fileNamed: "FutureScene")
  
  var delegate: ZoomProtocol?
  var delegateDialogue: CallDialogue?
   var hologram: SKSpriteNode?
  var inventoryItemDelegate: InventoryItemDelegate?
  
  var monitorDireita: SKSpriteNode?
  var dialogueStep = 0
  var holograma1peca = false // bool de estado para colocar a segunda peça do holograma
  
  var delegateRemove: RemoveProtocol?
  var delegateRemove2: RemoveProtocol2?
  
  let hologramaAnimate =  SKAction.animate(with: [SKTexture(imageNamed: "cartazCompleto"), SKTexture(imageNamed: "cartaz1"), SKTexture(imageNamed: "cartaz2"), SKTexture(imageNamed: "cartaz3"), SKTexture(imageNamed: "cartaz4"), SKTexture(imageNamed: "cartaz5"), SKTexture(imageNamed: "cartaz6")], timePerFrame: 0.3)
  
    // inicializador que adiciona os nós presentes no holograma e salva os progressos do userdefault
    init(delegate: ZoomProtocol, delegateRemove: RemoveProtocol, delegateRemove2: RemoveProtocol2, delegateDialogue: CallDialogue) {
    super.init()
    self.delegate = delegate
    self.delegateRemove = delegateRemove
    self.delegateRemove2 = delegateRemove2
    self.delegateDialogue = delegateDialogue
    self.zPosition = 1
    
    
    
    if let future {
      hologram = future.childNode(withName: "hologram") as? SKSpriteNode
      hologram?.removeFromParent()
      monitorDireita = future.childNode(withName: "monitorDireita") as? SKSpriteNode
      monitorDireita?.removeFromParent()
      
      self.isUserInteractionEnabled = true
    }
    
    if let hologram, let monitorDireita{
      self.addChild(hologram)
      self.addChild(monitorDireita)
    }
    
    monitorDireita?.isPaused = false
    startBlinkAnimation() // animação do monitorDireita piscando para sempre
    
      if UserDefaultsManager.shared.hologramComplete1 == true {
          hologram?.run(.setTexture(SKTexture(imageNamed: "cartazComChip")))
          delegateRemove.removePeca()
          hologram?.texture = SKTexture(imageNamed: "cartazComChip")
          holograma1peca = true
          
      }
      
      if UserDefaultsManager.shared.hologramComplete2 == true {
          hologram?.run(.setTexture(SKTexture(imageNamed: "cartazComPeca")))
          delegateRemove2.removePeca()
          hologram?.texture = SKTexture(imageNamed: "cartazComPeca")
          holograma1peca = true
          
      }
      
      if UserDefaultsManager.shared.hologramComplete3 == true {
          hologram?.run(.setTexture(SKTexture(imageNamed: "cartazCompleto")))
          monitorDireita?.isHidden = true
          delegateRemove.removePeca()
          delegateRemove2.removePeca()
          hologram?.texture = SKTexture(imageNamed: "cartazCompleto")

      }
        
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func startBlinkAnimation() {
    let duration = 0.5 // Duração de cada ciclo de animação em segundos
    let fadeInAction = SKAction.fadeIn(withDuration: duration / 2.0)
    let fadeOutAction = SKAction.fadeOut(withDuration: duration / 2.0)
    
    // Cria uma sequência de ações para o efeito de aparecer e desaparecer
    let blinkAction = SKAction.sequence([fadeOutAction, fadeInAction])
    
    // Repete a sequência para a animação continuar indefinidamente
    let repeatAction = SKAction.repeatForever(blinkAction)
    
    // Executa a animação no nó
    monitorDireita?.run(repeatAction)
  }
    
    func startBlinkAnimation2() {
        let duration = 1.0 // Duração de cada ciclo de animação em segundos
      let fadeInAction = SKAction.fadeIn(withDuration: duration / 2.0)
      let fadeOutAction = SKAction.fadeOut(withDuration: duration / 2.0)
      
      // Cria uma sequência de ações para o efeito de aparecer e desaparecer
      let blinkAction = SKAction.sequence([fadeOutAction, fadeInAction])
      
      // Repete a sequência para a animação continuar indefinidamente
      let repeatAction = SKAction.repeatForever(blinkAction)
      
      // Executa a animação no nó
      monitorDireita?.run(repeatAction)
    }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return } // se nao estiver em toque acaba aqui
    let location = touch.location(in: self)
    let tappedNodes = nodes(at: location)
    guard let tapped = tappedNodes.first else { return } // ter ctz que algo esta sendo tocado
    
    switch tapped.name {
    case "monitorDireita":
      delegate?.zoom(isZoom: true, node: hologram, ratio: 0.2)
    case "hologram":
        // colocar o segundo item no holograma
      if delegate?.didZoom == true && (HUD.shared.itemSelecionado == HUD.shared.peca1 || HUD.shared.itemSelecionado == HUD.shared.peca2) && holograma1peca && HUD.shared.itemSelecionado != nil{
        print("pecas completas colocada")
          hologram?.run(hologramaAnimate)
        delegate?.didZoom = false // setamos o didZoom para false para conseguir mudar o scale do zoom ao rodar a animação do holograma
        delegate?.zoom(isZoom: true, node: monitorDireita, ratio: 0.3) // o zoom vai para o monitorDireita com ratio 0.3
        GameScene.shared.hud.isHidden = true // esconde o inventário
          for item in HUD.shared.inventario {
              item.isHidden = true
          }
        GameScene.shared.invisible?.isHidden = false // tira o invisible do hidden para evitar algum clique na tela
          self.run(SKAction.wait(forDuration: 2)){ // delay de 2s para rodar os comandos
            GameScene.shared.invisible?.isHidden = true // deixa o invisible hidden para poder receber o clique na tela
              if self.dialogueStep == 0{
                  self.delegateDialogue?.dialogue(node: self.monitorDireita, texture: SKTexture(imageNamed: "dialogueHologram01"), ratio: 0.3, isHidden: false) // chama o dialogo final na cena
                  self.dialogueStep = 1
              }
          }

        monitorDireita?.isHidden = true
        delegateRemove?.removePeca()
        delegateRemove2?.removePeca()
          UserDefaultsManager.shared.hologramComplete3 = true
          UserDefaultsManager.shared.theEnd = true
      }
        // se caso colocar a peça do relogio primeiro no holograma
      if delegate?.didZoom == true && HUD.shared.itemSelecionado == HUD.shared.peca1 && !holograma1peca && HUD.shared.itemSelecionado != nil{
        print("peca1 colocada")
          startBlinkAnimation2()
        hologram?.run(.setTexture(SKTexture(imageNamed: "cartazComChip"))) // muda textura para com holograma com apenas o chip colocada
        delegateRemove?.removePeca()
        holograma1peca = true
          UserDefaultsManager.shared.hologramComplete1 = true
      }
        // se caso colocar a peça do cofre primeiro no holograma
      if delegate?.didZoom == true && HUD.shared.itemSelecionado == HUD.shared.peca2 && !holograma1peca && HUD.shared.itemSelecionado != nil{
        print("peca2 colocada")
          startBlinkAnimation2()
        hologram?.run(.setTexture(SKTexture(imageNamed: "cartazComPeca"))) // muda textura para com holograma com apenas a peca colocada
        delegateRemove2?.removePeca()
        holograma1peca = true
          UserDefaultsManager.shared.hologramComplete2 = true
      }
        // deselecionar o item
      if let selectedItem = HUD.shared.itemSelecionado {
        HUD.shared.removeBorder(from: selectedItem)
      }
      delegate?.zoom(isZoom: true, node: hologram, ratio: 0.2)
      
    default:
      return
    }
    inventoryItemDelegate?.clearItemDetail() // deselecionar os itens que dao zoom
  }
  
}
