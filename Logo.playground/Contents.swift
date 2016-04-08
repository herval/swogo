//: Playground - noun: a place where people can play

import UIKit
import SpriteKit
import XCPlayground


class Turtle {
    var drawing: Bool = true
    var angle: CGFloat = 0.0
    
    let body: SKSpriteNode!
    private let scene: SKScene!
    
    init(scene: SKScene, position: CGPoint) {
        self.scene = scene
        self.body = SKSpriteNode(color: SKColor.redColor(), size: CGSizeMake(20, 20))
        self.body.position = position
    }
    
    private func move(amount: Int) {
        // TODO animate the movement
        let newX = body.position.x + (cos(angle) * CGFloat(amount))
        let newY = body.position.y + (sin(angle) * CGFloat(amount))

        let newPos = CGPointMake(newX, newY)
        
        if(drawing) {
            drawLine(body.position, to: newPos)
        }
        body.position = newPos
    }
    
    private func rotate(angle: CGFloat) {
        self.angle += angle
    }
    
    private func setDrawing(drawing: Bool) {
        self.drawing = drawing
    }
    
    
    private func drawLine(from: CGPoint, to: CGPoint) {
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, from.x, from.y)
        CGPathAddLineToPoint(path, nil, to.x, to.y)
        
        let line = SKShapeNode(path: path)
        line.strokeColor = UIColor.redColor()
        line.lineWidth = 3
        scene.addChild(line)
    }

}

enum Command {
    case Move(amount: Int)
    case Rotate(amount: CGFloat)
    case PenUp
    case PenDown
}

class Interpreter {
    
//    let expressions: Dictionary<String, NSRegularExpression>
    
    let commands: Dictionary<String, (String) -> (Command)> = [
        "forward": { suffix in
            Command.Move(
                amount: Int(suffix)!
            )
        },
        "back": { suffix in
            Command.Move(
                amount: -Int(suffix)!
            )
        },
        "left": { suffix in
            Command.Rotate(
                amount: CGFloat(Int(suffix)!)
            )
        },
        "right": { suffix in
            Command.Rotate(
                amount: CGFloat(Int(suffix)!)
            )
        },
        "penup": { _ in
            Command.PenUp
        },
        "pendown": { _ in
            Command.PenDown
        }
    ]
    
    init() {
//        try! expressions = [
//            "forward": NSRegularExpression(pattern: "(forward|fd) (\\d+)", options: [])
//        ]
    }
    
    func param() {
        
    }
    
    func parse(command: String) -> Command? {
        // TODO REGEXP
        
        
        for key in commands.keys {
            if(command.hasPrefix(key)) {
                let params = command.stringByReplacingOccurrencesOfString(key, withString: "").stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                
                return commands[key]!(params)
            }
        }
        
//        let fwd = matches(expressions["forward"]!, input: command)
//        if(fwd.count > 0) {
//            fwd.forEach { r in
//                print(command)
//                print(r.rangeAtIndex(1))
//            }
//        }
    
        
//        switch command {
//        case /forward/: Command.Move(amount: 10)
//        }
        return Command.Move(amount: 10)
    }
    
    private func matches(expression: NSRegularExpression, input: String) -> [NSTextCheckingResult] {
        return expression.matchesInString(input, options: [], range: NSMakeRange(0, input.characters.count))
    }
}


class Sandbox {
    let scene: SKScene!
    let turtle: Turtle!
    let interpreter: Interpreter!
    
    init(boardSize: CGSize) {
        scene = SKScene(size: CGSizeMake(frame.width, frame.height))
        
        turtle = Turtle(scene: scene, position: CGPointMake(boardSize.width/2, boardSize.height/2))
        scene.addChild(turtle.body)
        
        interpreter = Interpreter()
    }
    
    func execute(command: String) -> String {
        guard let cmd = interpreter.parse(command) else {
            return "Don't recognize \(command)!"
        }
        switch cmd {
            case .Move(let amount): turtle.move(amount)
            case .Rotate(let amount): turtle.rotate(amount)
            case .PenUp: turtle.setDrawing(false)
            case .PenDown: turtle.setDrawing(true)
        }
        return "OK"
    }
}



let frame = CGRectMake(0, 0, 800, 800)
let view = SKView(frame: frame)
view.contentMode = .ScaleAspectFill

XCPlaygroundPage.currentPage.liveView = view



let sandbox = Sandbox(boardSize: CGSizeMake(800, 800))

view.presentScene(sandbox.scene)



//let input = UITextField(frame: CGRectMake(0, frame.height-30, frame.width, 30))
//input.font = UIFont(name: "Courier New", size: 15)!
//input.attributedPlaceholder = NSAttributedString(
//    string: "Click here to enter your commands.",
//    attributes:[
//        NSForegroundColorAttributeName: UIColor.whiteColor(),
//        NSFontAttributeName: input.font!
//    ])
//
//input.textColor = UIColor.whiteColor()
//input.backgroundColor = UIColor.blueColor()
//
//print("FOO")
//
//class KeyHandler: NSObject, UITextFieldDelegate {
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        guard let text = textField.text else {
//            return true
//        }
//        sandbox.execute(text)
//        
//        return true
//    }
//    
//}
//input.delegate = KeyHandler()
//
//view.addSubview(input)



print(sandbox.execute("penup"))
print(sandbox.execute("forward 50"))
print(sandbox.execute("pendown"))
print(sandbox.execute("forward 100"))
print(sandbox.execute("right 90"))
print(sandbox.execute("forward 100"))
print(sandbox.execute("left 90"))
print(sandbox.execute("forward 200"))
print(sandbox.execute("penup"))
print(sandbox.execute("back 300"))
//print(sandbox.execute("forward 100"))
//print(sandbox.execute("forward 150"))

