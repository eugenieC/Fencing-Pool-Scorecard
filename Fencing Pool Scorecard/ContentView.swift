import SwiftUI

// scorecard header format
struct headerFormat: View {
    var text:String
    var cellSize:CGFloat
    
    var body: some View {
        
        Text(text)
            .font(Font.body.bold())
            .foregroundStyle(.yellow)
            .frame(width: CGFloat(text == "VM" || text=="Ind" ? (cellSize+4):cellSize), height: cellSize)
            .scaledToFill()
            .background(Color(#colorLiteral(red: 0.29411764705882354, green: 0.4235294117647059, blue: 0.6196078431372549, alpha: 1)))
            .overlay(
                RoundedRectangle(cornerRadius: 1)
                    .stroke(Color.gray, lineWidth: 1)
            )

    }
}

// fill scorecard cell
struct scoreCardCell: View {
    var cellValue:String
    var cellSize:CGFloat
    var colorRed:Float
    var colorGreen:Float
    var colorBlue:Float
    var widerCell:Int
    
    @Environment(\.colorScheme) var colorScheme  // to change text color for dark mode
    
    var body: some View {
        
        Text(cellValue)
            .frame(width: (widerCell == 1 ? (cellSize + 4):cellSize), height: cellSize)
            .scaledToFill()
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .foregroundColor(colorScheme == .dark ? Color.black : Color.black)
            .background(Color(#colorLiteral(red: colorRed, green: colorGreen, blue: colorBlue, alpha: 1)))
            .overlay(
                RoundedRectangle(cornerRadius: 1)
                    .stroke(Color.gray, lineWidth: 1)
            )
    }
}


//  build scorecard table and fill the values
struct  scoreCard: View {
    var matrix:[[String]]
    var numFencer:Int
    var cellSize:CGFloat
    
    let headerVSRI = ["V", "VM", "TS", "TR", "Ind"]
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
            let nMatrixCol = numFencer + headerVSRI.count
            VStack(spacing: 1) {
                HStack(spacing: 1) {
                    headerFormat(text: " ",cellSize:cellSize)
                    ForEach(0..<numFencer,id: \.self) { colm in
                        headerFormat(text: "\(colm+1)",cellSize:cellSize)
                    }
                    ForEach(headerVSRI, id: \.self) { label in
                        headerFormat(text: label,cellSize:cellSize)
                    }
                }
                VStack(spacing: 1) {
                    ForEach(0..<numFencer, id: \.self) { rowIndex in
                        HStack(spacing: 1) {
                            // first column in the table
                            headerFormat(text:"\(rowIndex+1)",cellSize:cellSize)
                            ForEach(0..<nMatrixCol, id: \.self) { colIndex in
                                
                                if rowIndex == colIndex {
                                    scoreCardCell(cellValue:matrix[rowIndex][colIndex],cellSize:cellSize,colorRed:0.8,colorGreen:0.8,colorBlue:0.8,widerCell: 0 )  // light grey  // extra space for #victory / #match ratio
                                } else if  matrix[rowIndex][colIndex].prefix(1) == "V" {
                                    scoreCardCell(cellValue:matrix[rowIndex][colIndex],cellSize:cellSize,colorRed:0.8,colorGreen:0.99,colorBlue:0.8,widerCell:0) // light
                                } else if  matrix[rowIndex][colIndex].prefix(1) == "D" {
                                    scoreCardCell(cellValue:matrix[rowIndex][colIndex],cellSize:cellSize,colorRed:0.9882352941,colorGreen:0.8,colorBlue:0.8,widerCell:0 ) // light pink
                                } else {
                                    scoreCardCell(cellValue:matrix[rowIndex][colIndex],cellSize:cellSize,colorRed:1,colorGreen:1,colorBlue:1,widerCell:(colIndex == (numFencer+1) || colIndex == (numFencer+4) ? 1 : 0)) // white
                                }
                            }
                        }
                    }
                }
            }.padding(5)
    }
}

// +/- stepper
struct stepperButton: View {
    var text:String
    var rangeMin:Int
    var rangeMax:Int
    @Binding var value:Int
    
    var body: some View {
        HStack(spacing:3) {
            Text(text)
                .font(Font.body.bold())
                .scaledToFill()

            Stepper("",
                    value:$value,
                    in: rangeMin...rangeMax,
                    step: 1)
            
            Text("\(self.value)")
                .scaledToFill()
            }
        }
    }

// list picker for position number
struct listPicker: View {
    var text:String
    var listForSelection:[Int]
    @Binding var selectedValue:Int
    
    var body: some View {
        HStack {
            Text(text)
                .font(Font.body.bold())
                .scaledToFill()

                Picker("", selection: $selectedValue) {
                    ForEach(listForSelection, id: \.self) { num in
                        Text("\(num)").font(.title).tag(num)
                        }
                    }.pickerStyle(MenuPickerStyle()) // use MenuPickerStyle to avoid overlap
            }
        }
    }

// scorecard header with reset button
struct scorecardTitle: View {
    @Binding var numFencer:Int
    @Binding var myPosition:Int
    @Binding var myScore: [Int]
    @Binding var oppoScore: [Int]
    @Binding var oppoPosition: [Int]
    @State var isResetting = false // a boolean state variable to track if the reset button was tapped
    
    var body: some View {
        ZStack {
            Text("Fencing Pool Scorecard")
                .font(.headline)
            
            HStack {
                Spacer()
                Button(action: {
                    isResetting = true // set the boolean state variable to true when the reset button is tapped
                }) {
                    Text("Reset")
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .alert(isPresented: $isResetting) {
            Alert(title: Text("Reset"), message: Text("Are you sure you want to reset?"), primaryButton: .destructive(Text("Reset"), action: {
                // perform the reset action here
                resetValues()
            }), secondaryButton: .cancel())
        }
    }
    
    func resetValues() {
        myPosition = 0
        numFencer = 7
        myScore = Array(repeating: 0, count: 8)
        oppoScore = Array(repeating: 0, count: 8)
        oppoPosition = Array(repeating: 0, count: 8)
    }
}


// input pannel
struct NaviView: View {
    @Binding var numFencer:Int
    @Binding var myPosition:Int
    @Binding var myScore: [Int]
    @Binding var oppoScore: [Int]
    @Binding var oppoPosition: [Int]
    
    var body: some View {
        NavigationView {
            List {
                VStack(spacing: 10) {
                    stepperButton(
                        text:"Fencers in Pool",
                        rangeMin:3,
                        rangeMax:7,
                        value:$numFencer)
                    
                    listPicker(text:"My Position"    ,listForSelection:makePositionArray(numFencer:numFencer), selectedValue:$myPosition)
                }
                
                
                ForEach(0..<(numFencer-1), id: \.self) { row in
                    HStack(spacing: -5) {
                        
                        Text("Bout \(row+1)")
                            .font(.system(size: 15))
                            .fontWeight(.bold)
                            .padding(7)
                            .border(.gray)
                            .rotationEffect(Angle(degrees: 90))
                            .padding(.leading, -20)
                        
                        VStack (spacing:10) {
                            stepperButton(
                                text:"My Score",
                                rangeMin:0,
                                rangeMax:5,
                                value:$myScore[row])
                            
                            stepperButton(
                                text:"Opponnet Score",
                                rangeMin:0,
                                rangeMax:5,
                                value:$oppoScore[row])
                            
                            if !(myScore[row] == 0 && oppoScore[row] == 0) && myScore[row] == oppoScore[row] {
                                ErrorView(errorMessage: "Tie Score in this bout")
                            }
                            
                            listPicker(text:"Opponent Position",listForSelection:makePositionArray(numFencer:numFencer), selectedValue:$oppoPosition[row])
                            
                            if myPosition != 0 && myPosition == oppoPosition[row] {
                                ErrorView(errorMessage: "Same position to my position")
                            }
                            
                            let duplicates = Set(oppoPosition.filter({ (name: Int) in oppoPosition.filter({ $0 == name && $0 != 0}).count > 1 }))
                            
                            if duplicates.count > 0 && duplicates.contains(oppoPosition[row]) {
                                ErrorView(errorMessage:"Duplicate positions: \(duplicates.map({ String($0) }).joined(separator: ", "))")
                            }
                        } // end of Vstack
                    }// end of HStack
                } // end of ForEach
            }//end of list
        }//end of navigationView
    } // end of body
    
    
    
    func makePositionArray(numFencer:Int) -> [Int] {
        let position = Array(0...numFencer)
        return position
    }
} // end of struct


// show error message in red text
struct ErrorView: View {
    let errorMessage: String

    var body: some View {
        VStack {
            Text(errorMessage)
                .foregroundColor(.red)
        }
    }
}


//--------------------------------------------------------------------------
// Main struct
//--------------------------------------------------------------------------
struct ContentView: View {
    
    @State private var myPosition = 0
    @State private var numFencer = 7
    @State private var myScore: [Int] = Array(repeating:0, count: 8)
    @State private var oppoScore: [Int] = Array(repeating:0, count: 8)
    @State private var oppoPosition: [Int] = Array(repeating:0, count: 8)
    @State private var isShowingDetailView = false

    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var scale: CGFloat = 1.0        // for zoom in & out
    @State private var xOffset: CGFloat = 0.0      // for scroll
    @State private var yOffset: CGFloat = 0.0      // for scroll
    
    @State private var poolMatrix: [[String]] = Array(repeating: Array(repeating: " ", count: 14), count: 8)
    let screenWidthNoSpace: CGFloat = (UIScreen.main.bounds.width)   // use when portrait
    let screenHeightNoSpace: CGFloat = (UIScreen.main.bounds.height)  // use when landscape

    var body: some View {
        
        GeometryReader { geometry in
            let screenWidth = geometry.frame(in: .global).width // measure wide of screen
            
            // if screen is portrait
            if  verticalSizeClass != .compact {
                VStack (spacing: -5) {
                    // Vstack part 1 - title & reset button
                    scorecardTitle(
                        numFencer:$numFencer,
                        myPosition:$myPosition,
                        myScore:$myScore,
                        oppoScore:$oppoScore,
                        oppoPosition:$oppoPosition)
                    
                    // Vstack part 2 - Scorecard matrix
                    scoreCard(matrix:calculateScorecard(numFencer:numFencer,myPosition:myPosition, myScore:myScore, oppoScore:oppoScore, oppoPosition:oppoPosition ,poolMatrix:poolMatrix)
                              ,numFencer:numFencer
                              ,cellSize:min(40,cellSizeCalc(numFencer:numFencer,screenWidth:screenWidth,portrait:1)))
                    
                    // Vstack part 3 - Data input
                    NaviView(
                        numFencer:$numFencer,
                        myPosition:$myPosition,
                        myScore:$myScore,
                        oppoScore:$oppoScore,
                        oppoPosition:$oppoPosition)
                }.navigationViewStyle(StackNavigationViewStyle()) // end of VStack
            }   // if screen is landscape
                else if  verticalSizeClass == .compact {
                HStack (spacing: 0) {
                    VStack (spacing:-5) {
                        // Vstack part 1 - title & reset button
                        scorecardTitle(
                            numFencer:$numFencer,
                            myPosition:$myPosition,
                            myScore:$myScore,
                            oppoScore:$oppoScore,
                            oppoPosition:$oppoPosition)
                        
                        // Vstack part 2 - Scorecard matrix
                        scoreCard(matrix:calculateScorecard(numFencer:numFencer,myPosition:myPosition, myScore:myScore, oppoScore:oppoScore, oppoPosition:oppoPosition ,poolMatrix:poolMatrix)
                                  ,numFencer:numFencer
                                  ,cellSize:cellSizeCalc(numFencer:numFencer,screenWidth:screenWidth,portrait:0))
                    }.frame(width:screenWidth / 2, height: geometry.size.height)
           
                    
                    Divider()
                    
                    // Vstack part 3 - Data input
                    GeometryReader { geometry in
                        NaviView(
                            numFencer:$numFencer,
                            myPosition:$myPosition,
                            myScore:$myScore,
                            oppoScore:$oppoScore,
                            oppoPosition:$oppoPosition)
                    // end of navigationview
                    }.frame(width:screenWidth / 2, height: geometry.size.height)
                     .navigationViewStyle(StackNavigationViewStyle())
                    
                } // end of Hstack
            } // end of else if
        }.scaleEffect(max(scale,1))
         .offset(x: xOffset, y: yOffset)
         .gesture(
                   MagnificationGesture()    // for zoom in & out
                       .onChanged { value in
                           self.scale = value.magnitude
                       }
                   )
    }  // end of body
    
    func calculateScorecard(numFencer:Int,myPosition:Int, myScore:[Int], oppoScore:[Int], oppoPosition:[Int] ,poolMatrix: [[String]]) -> [[String]] {

        let rowCount = poolMatrix.count
        let colCount = poolMatrix[0].count
        
        var myV = 0
        var myM = 0
        var myTS = 0
        var myTR = 0
        var result = Array(repeating: Array(repeating: " ", count: colCount), count: rowCount)
        
        for i in 0..<numFencer {
            let myS   = myScore[i]
            let oppoS = oppoScore[i]
            let myP   = myPosition
            let oppoP = oppoPosition[i]
            
            if !(myS == 0 && oppoS == 0) &&
                (myP != oppoP) &&
                (myS > -1 && oppoS > -1 && myP > 0 && oppoP > 0) {
                myM = myM + 1
                myTS = myTS + myS
                myTR = myTR + oppoS
                if myS > oppoS {
                    result[myP-1][oppoP-1] = "V"+String(myS)
                    result[oppoP-1][myP-1] = "D"+String(oppoS)
                    myV = myV + 1
                    
                } else {
                    result[myP-1][oppoP-1] = "D"+String(myS)
                    result[oppoP-1][myP-1] = "V"+String(oppoS)
                }
                result[myP-1][numFencer] = String(myV)
                result[myP-1][numFencer+1] = String(format: "%.2f",Double(myV)/Double(myM))
                result[myP-1][numFencer+2] = String(myTS)
                result[myP-1][numFencer+3] = String(myTR)
                result[myP-1][numFencer+4] = String(myTS - myTR)
            }
        }
        return result
    }
}

func cellSizeCalc(numFencer:Int,screenWidth:CGFloat,portrait:Int) -> CGFloat {
    var cellSize: CGFloat = 10
    let headerVSRI = ["V", "VM", "TS", "TR", "Ind"]
    let nCol : CGFloat = CGFloat(numFencer) + CGFloat(headerVSRI.count)
    
    if  portrait == 1 {
        cellSize =  (screenWidth-30) / (nCol+1)
    } else {
        cellSize = (screenWidth/2-30) / (nCol+1)
    }
    return cellSize
}
    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
//            .previewInterfaceOrientation(.landscapeLeft)
    }
}














