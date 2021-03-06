//: Playground - noun: a place where people can play

import UIKit
import SpriteKit
import XCPlayground


class Turtle {
    var drawing: Bool = true
    var angle: CGFloat = 90.0
    
    let body: SKShapeNode!
    private let scene: SKScene!
    
    init(scene: SKScene, position: CGPoint) {
        self.scene = scene
    
        self.body = SKShapeNode(path: Turtle.bodyShape(position), centered: true)
        self.body.strokeColor = UIColor.redColor()
        self.body.fillColor = UIColor.redColor()
        self.body.lineWidth = 3
        self.body.position = position
    }
    
    private func move(amount: Int) {
        // TODO animate the movement
        let newX = body.position.x + (cos(radians(angle)) * CGFloat(amount))
        let newY = body.position.y + (sin(radians(angle)) * CGFloat(amount))

        let newPos = CGPointMake(newX, newY)
        
        if(drawing) {
            drawLine(body.position, to: newPos)
        }
        
// TODO
//        self.body.runAction(
//            SKAction.moveTo(newPos, duration: 0.2)
//        )
        body.position = newPos
    }
    
    private func rotate(angle: CGFloat) {
        self.angle += angle
        
// TODO
//        self.body.runAction(
//            SKAction.rotateByAngle((angle * CGFloat(M_PI)/180.0), duration: 0.2)
//        )
        self.body.zRotation = radians(angle)
    }
    
    private func radians(angle: CGFloat) -> CGFloat {
        return (angle * CGFloat(M_PI)/180.0)
    }
    
    private func setDrawing(drawing: Bool) {
        self.drawing = drawing
    }
    
    private static func bodyShape(position: CGPoint) -> CGPath {
        let path = UIBezierPath()
        
        let side: CGFloat = 10
        
        path.moveToPoint(CGPointMake(position.x, position.y+side))
        path.addLineToPoint(CGPointMake(position.x-side, position.y-side))
        path.addLineToPoint(CGPointMake(position.x+side, position.y-side))
        path.addLineToPoint(CGPointMake(position.x, position.y+side))
        path.closePath()
        
        return path.CGPath
    }
    
    private func drawLine(from: CGPoint, to: CGPoint) {
        let path = UIBezierPath()
        path.moveToPoint(from)
        path.addLineToPoint(to)
        
        let line = SKShapeNode(path: path.CGPath)
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
    case Repeat(times: Int, commands: Array<Command>)
}

class Interpreter {
    
    
    struct CommandRepresentation {
        let params: Int
        let eval: ([String]) -> (Command)
    }
    
    private static let commands: Dictionary<String, CommandRepresentation> = [
        "forward": CommandRepresentation(
            params: 1,
            eval: { suffix in
                Command.Move(amount: Int(suffix[0])!)
            }
        ),
        "back": CommandRepresentation(
            params: 1,
            eval: { suffix in
                Command.Move(amount: -Int(suffix[0])!)
            }
        ),
        "left": CommandRepresentation(
            params: 1,
            eval: { suffix in
                Command.Rotate(amount: CGFloat(Int(suffix[0])!))
            }
        ),
        "right": CommandRepresentation(
            params: 1,
            eval: { suffix in
            Command.Rotate(amount: -CGFloat(Int(suffix[0])!))
            }
        ),
        "penup": CommandRepresentation(
            params: 0,
            eval: { _ in Command.PenUp }
        ),
        "pendown": CommandRepresentation(
            params: 0,
            eval: { _ in Command.PenDown }
        ),
        "repeat": CommandRepresentation(
            params: 2,
            eval: { countAndCommands in
//                print("evaluating repeat: \(countAndCommands)")
                
                let count = Int(countAndCommands[0])!
                let commands = Interpreter.split(countAndCommands[1])
//                print("block: \(commands)")
                
                let parsed = Interpreter.parseAll(commands)
//                print(parsed)
                return Command.Repeat(times: count, commands: parsed)
            }
        )
    ]
    
    private static func parseAll(tokens: Array<String>) -> [Command] {
        var cmds: Array<Command> = []
        var i = 0
        
//        print(tokens)
        while(i <= tokens.count-1) {
            guard let cmd = Interpreter.commands[tokens[i]] else {
                // no command found - fail the entire parsing
                return []
            }
            
            // consume the command + params
//            print(tokens)
            let params = Array(tokens[(i+1)..<(i+1+cmd.params)])
            let command = cmd.eval(params)
            cmds.append(command)
            
            i += cmd.params+1
        }
        
        return cmds
    }
    
    private static func split(input: String) -> Array<String> {
        var str = input
        if(str.hasPrefix("[")) { // unwrapping a list
//            print("unwrapping list: \(str)")
            str = String(str.characters.dropFirst().dropLast())
        }
        let parts = str.componentsSeparatedByString(" ")
        var tokens: Array<String> = []
        var i = 0
        while(i <= parts.count-1) {
            if(parts[i].hasPrefix("[")) { // keep a list as a single string, instead of breaking it down
                let j = parts.indexOf { str in
                    str.hasSuffix("]")
                }!
                let list = Array(parts[i..<(j+1)]).joinWithSeparator(" ")
//                print("List: \(list)")
                tokens.append(list)
                i = j+1
            } else {
                tokens.append(parts[i])
                i += 1
            }
        }
        
//        print("Final tokens: \(tokens)")
        
        return tokens
    }
    
    func parse(command: String) -> [Command] {
        return Interpreter.parseAll(Interpreter.split(command))
    }
    
//    private func matches(expression: NSRegularExpression, input: String) -> [NSTextCheckingResult] {
//        return expression.matchesInString(input, options: [], range: NSMakeRange(0, input.characters.count))
//    }
}


class Sandbox {
    let scene: SKScene!
    let turtle: Turtle!
    let interpreter: Interpreter!
    
    init(boardSize: CGSize) {
        scene = SKScene(size: boardSize)
        
        turtle = Turtle(scene: scene, position: CGPointMake(boardSize.width/2, boardSize.height/2))
        scene.addChild(turtle.body)
        
        interpreter = Interpreter()
    }
    
    func execute(command: String) -> String {
        let cmd = interpreter.parse(command)
        if(cmd.isEmpty) {
            return "Don't recognize \(command)"
        }
        cmd.forEach { c in
            exec(c)
        }
        return "OK"
    }
    
    private func exec(cmd: Command) {
        switch cmd {
        case .Move(let amount): turtle.move(amount)
        case .Rotate(let amount): turtle.rotate(amount)
        case .PenUp: turtle.setDrawing(false)
        case .PenDown: turtle.setDrawing(true)
        case .Repeat(let times, let commands):
            (0..<times).forEach { _ in
                commands.forEach { cmd in
                    exec(cmd)
                }
            }
        }
    }
}


class App: NSObject, UITextFieldDelegate {
    
    var view: SKView!
    var sandbox: Sandbox!

    override init() {
        super.init()
        let frame = CGRectMake(0, 0, 800, 800)
        view = SKView(frame: frame)
        view.contentMode = .ScaleAspectFill
        
        sandbox = Sandbox(boardSize: CGSizeMake(800, 800))
        view.presentScene(sandbox.scene)

        setupInput()
    }
    
    private func setupInput() {
        let input = UITextField(frame: CGRectMake(0, view.frame.height-30, view.frame.width, 30))
        input.font = UIFont(name: "Courier New", size: 15)!
        input.autocorrectionType = .No
        input.autocapitalizationType = .None
        input.attributedPlaceholder = NSAttributedString(
            string: "Click here to enter your commands.",
            attributes:[
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: input.font!
            ])
        
        input.textColor = UIColor.whiteColor()
        input.backgroundColor = UIColor.blueColor()
        
        let handler = self
        input.delegate = handler
        
        view.addSubview(input)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.attributedPlaceholder = nil
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        
        if(string.hasSuffix("\n")) {
            sandbox.execute(text)
            textField.text = ""
            return false
        }
        
        return true
    }

}



let app = App()
XCPlaygroundPage.currentPage.liveView = app.view



//print(app.sandbox.execute("repeat 15 [penup forward 10 pendown forward 5] penup back 300"))
print(app.sandbox.execute("repeat 360 [forward 1 left 1]"))
//print(app.sandbox.execute("forward 50"))
//print(app.sandbox.execute("pendown"))
//print(app.sandbox.execute("forward 100"))
//print(app.sandbox.execute("right 45"))
//print(app.sandbox.execute("forward 100"))
//print(app.sandbox.execute("left 90"))
//print(app.sandbox.execute("forward 200"))
//print(app.sandbox.execute("penup"))
//print(app.sandbox.execute("back 300"))

//print(sandbox.execute("repeat :count [penup forward 4 pendown forward 4]"))

//print(sandbox.execute("forward 100"))
//print(sandbox.execute("forward 150"))

