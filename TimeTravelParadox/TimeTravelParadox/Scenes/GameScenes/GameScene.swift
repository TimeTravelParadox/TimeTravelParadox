import SpriteKit
import AVFoundation

class GameScene: SKScene, ZoomProtocol{
    
    static let shared = GameScene()
    
    private var past: Past?
    private var future: Future?
    private let hud = HUD()
    private let qg = QG()
    
    var isTravelingSFXPlaying = false
    var isBackToQGSFXPlaying = false
    
    var zooming = true
    
    private var audioPlayerPastST: AVAudioPlayer?
    private var audioPlayerQGST: AVAudioPlayer?
    private var audioPlayerFutureST: AVAudioPlayer?
    
    
    private var fade: Fade?
    
      var itemDetail: ItemDetail?
  
    let zoomSound = SKAction.playSoundFileNamed("zoomSound", waitForCompletion: false)
    let travelingSFX = SKAction.playSoundFileNamed("traveling.mp3", waitForCompletion: true)
    let backToQGSFX = SKAction.playSoundFileNamed("backToQG.mp3", waitForCompletion: true)
    
    let cameraNode = SKCameraNode()
    var cameraPosition = CGPoint(x: 0, y: 0)
    
    var didZoom = false
    var ratio: CGFloat?
    
    func setupCamera(){
        cameraNode.position = cameraPosition
        addChild(cameraNode)
        camera = cameraNode
        GameScene.shared.camera = camera
    }
    
    // Função para reposicionar o inventário
    func positionNodeRelativeToCamera(_ node: SKSpriteNode, offsetX: CGFloat, offsetY: CGFloat) {
        if let camera = camera {
            let cameraPositionInScene = convert(camera.position, to: self)
            let newPosition = CGPoint(x: cameraPositionInScene.x + offsetX, y: cameraPositionInScene.y + offsetY)
            node.position = newPosition
        }
    }
    
    func zoom(isZoom: Bool, node: SKSpriteNode?, ratio: CGFloat){
        guard didZoom != isZoom else {
            return
        }
        
        if zooming{
            zooming = false
            if isZoom {
                // Deselecionar o item
                if HUD.shared.isSelected {
                    if HUD.shared.itemSelecionado != nil {
                        HUD.shared.removeBorder(from: HUD.shared.itemSelecionado!)
                    }
                }
                self.didZoom = isZoom
                self.cameraPosition = node?.position ?? self.cameraNode.position
                self.cameraNode.position = self.cameraPosition
                self.cameraNode.run(SKAction.scale(to: ratio, duration: 0))
                GameScene.shared.cameraPosition = self.cameraNode.position
                GameScene.shared.ratio = ratio
                hud.reposiconarInvIn(ratio: ratio)
                for (index, item) in HUD.shared.inventario.enumerated() {
                    item.size = CGSize(width: 30*ratio, height: 30*ratio)
                    switch index {
                    case 0:
                        self.positionNodeRelativeToCamera(item, offsetX: -50*ratio, offsetY: 144*ratio)
                    case 1:
                        self.positionNodeRelativeToCamera(item, offsetX: 0, offsetY: 144*ratio)
                    case 2:
                        self.positionNodeRelativeToCamera(item, offsetX: 50*ratio, offsetY: 144*ratio)
                    case 3:
                        self.positionNodeRelativeToCamera(item, offsetX: 100*ratio, offsetY: 144*ratio)
                    case 4:
                        self.positionNodeRelativeToCamera(item, offsetX: 150*ratio, offsetY: 144*ratio)
                    default:
                        return
                    }
                }
                fade?.fade(camera: cameraNode.position)
                node?.isPaused = false
                node?.run(zoomSound)
                hud.hideTravelQG(isHide: true)
            } else {

                // Deselecionar o item
                if HUD.shared.isSelected && HUD.shared.itemSelecionado != nil {
                    HUD.shared.removeBorder(from: HUD.shared.itemSelecionado!)
                }
                self.didZoom = isZoom
                self.cameraNode.position = node?.position ?? self.cameraNode.position
                self.cameraNode.run(SKAction.scale(to: 1, duration: 0))
                GameScene.shared.cameraPosition = self.cameraNode.position
                GameScene.shared.ratio = 1
                HUD.shared.inventarioHUD?.size = CGSize(width: 320, height: 50)
                HUD.shared.inventarioHUD?.position = CGPoint(x: 80, y: 145)
                hud.reposiconarInvOut()
                for (index, item) in HUD.shared.inventario.enumerated() {
                    item.size = CGSize(width: 30, height: 30)
                    switch index {
                    case 0:
                        self.positionNodeRelativeToCamera(item, offsetX: -50, offsetY: 144)
                    case 1:
                        self.positionNodeRelativeToCamera(item, offsetX: 0, offsetY: 144)
                    case 2:
                        self.positionNodeRelativeToCamera(item, offsetX: 50, offsetY: 144)
                    case 3:
                        self.positionNodeRelativeToCamera(item, offsetX: 100, offsetY: 144)
                    case 4:
                        self.positionNodeRelativeToCamera(item, offsetX: 150, offsetY: 144)
                    default:
                        return
                    }
                }
                fade?.fade(camera: cameraNode.position)
                node?.isPaused = false
                node?.run(zoomSound)
                print("zoom out")
                hud.hideTravelQG(isHide: false)
                
            }
            
            self.run(SKAction.wait(forDuration: 0.4)){

                self.zooming = true
            }
        }
    }
    
    var futurePlayingST = false
    
    override func didMove(to view: SKView) {
        self.past = Past(delegate: self)
        if let past {
            addChild(past)
            past.zPosition = 0
        }
        // MARK: referencias das trilhas sonoras
        // trilha sonora do passado
        if let audioURLPastST = Bundle.main.url(forResource: "pastST", withExtension: "mp3") {
            do {
                audioPlayerPastST = try AVAudioPlayer(contentsOf: audioURLPastST)
                audioPlayerPastST?.numberOfLoops = -1 // reproduz em ciclo infinito
                audioPlayerPastST?.volume = 0
                audioPlayerPastST?.prepareToPlay()
            } catch {
                print("Erro ao carregar o arquivo de som A: \(error)")
            }
        }
        //trilha sonora do qg
        if let audioURLQGST = Bundle.main.url(forResource: "QGST", withExtension: "mp3") {
            do {
                audioPlayerQGST = try AVAudioPlayer(contentsOf: audioURLQGST)
                audioPlayerQGST?.numberOfLoops = -1 // reproduz em ciclo infinito
                audioPlayerQGST?.volume = 0
                audioPlayerQGST?.prepareToPlay()
            } catch {
                print("Erro ao carregar o arquivo de som A: \(error)")
            }
        }
        // trilha sonora do futuro
        if let audioURLFutureST = Bundle.main.url(forResource: "futureST", withExtension: "mp3") {
            do {
                audioPlayerFutureST = try AVAudioPlayer(contentsOf: audioURLFutureST)
                audioPlayerFutureST?.numberOfLoops = -1 // reproduz em ciclo infinito
                audioPlayerFutureST?.volume = 0
                audioPlayerFutureST?.prepareToPlay()
            } catch {
                print("Erro ao carregar o arquivo de som A: \(error)")
            }
        }
        audioPlayerQGST?.play() // toca a música assim que inicia
        fadeInAudioPlayer(audioPlayerQGST)

        
        
        self.future = Future(delegate: self, pastScene: past!)
        if let future {
            addChild(future)
            future.zPosition = 0
        }
        
        self.fade = Fade()
        if let fade {
            addChild(fade)
            fade.zPosition = 25
        }
        
        setupCamera()
        
        addChild(hud)
        addChild(qg)
        
        qg.zPosition = 20
        hud.zPosition = 14
        hud.hideQGButton(isHide: true)
//        hud.hideTravelButton(isHide: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return } // se nao estiver em toque acaba aqui
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        guard let tapped = tappedNodes.first else { return } // ter ctz que algo esta sendo tocado
        if tapped == past?.clock?.peca1 {
            print("print past clock peca1 da gamescene")
        }
        switch tapped.name {
        case "qgButton":
            if isBackToQGSFXPlaying{
                return
            }
            scene?.run(backToQGSFX)
            scene?.run(SKAction.wait(forDuration: 1.9)){
                self.qg.zPosition = 20
                self.past?.zPosition = 0
                self.future?.zPosition = 0
                self.hud.hideQGButton(isHide: true)
                self.fadeInAudioPlayer(self.audioPlayerQGST)
                self.audioPlayerQGST?.play()
                self.audioPlayerPastST?.pause()
                self.audioPlayerFutureST?.pause()
                self.past?.light?.isHidden = true

            }
            isBackToQGSFXPlaying = false
        case "travel":
            if isTravelingSFXPlaying {
                return
            }
            
            // marca o estado do som tocando
            isTravelingSFXPlaying = true

            scene?.run(travelingSFX)
            scene?.run(SKAction.wait(forDuration: 1.9)) {
                if self.past?.zPosition ?? 0 > 0  {
                    self.past?.zPosition = 0
                    self.qg.zPosition = 0
                    self.future?.zPosition = 10
                    self.hud.hideQGButton(isHide: false)
                    self.audioPlayerQGST?.pause()
                    self.audioPlayerPastST?.pause()
                    self.fadeInAudioPlayer(self.audioPlayerFutureST)
                    self.audioPlayerFutureST?.play()
                    self.past?.light?.isHidden = true


                } else {
                    self.qg.zPosition = 0
                    self.future?.zPosition = 0
                    self.past?.zPosition = 10
                    self.hud.hideQGButton(isHide: false)
                    self.audioPlayerQGST?.pause()
                    self.fadeInAudioPlayer(self.audioPlayerPastST)
                    self.audioPlayerPastST?.play()
                    self.audioPlayerFutureST?.pause()
                    self.past?.light?.isHidden = false
                }

                // marca som finalizado
                self.isTravelingSFXPlaying = false
            }

        default:
            return
        }
    }
    
    func fadeInAudioPlayer(_ audioPlayer: AVAudioPlayer?) {
        let fadeDuration: TimeInterval = 10.0
        let fadeSteps: Int = 1000
        let fadeStepDuration: TimeInterval = fadeDuration / TimeInterval(fadeSteps)
        let maxVolume: Float = 0.2 // voluke final
        
        // inicia o fade in
        DispatchQueue.global(qos: .userInteractive).async {
            for step in 0...fadeSteps {
                // Calcule o novo volume com base na etapa atual do fade-in
                let volume = Float(step) / Float(fadeSteps) * maxVolume
                
                // Atualize o volume do áudio no thread principal
                DispatchQueue.main.async {
                    audioPlayer?.volume = volume
                }
                
                // Espere o próximo passo do fade-in
                Thread.sleep(forTimeInterval: fadeStepDuration)
            }
        }
    }
}
