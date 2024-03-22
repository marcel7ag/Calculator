import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'toggletheme.dart';
import 'history.dart';

class Calculator extends StatefulWidget{
  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String userInput = "";
  String result = "0";
  FocusNode _focuseNode = FocusNode();
  List<String> calculationHistory = [];

  @override
  void initState() {
    super.initState();
    _focuseNode.requestFocus();
  }

  @override
  void dispose() {
    _focuseNode.dispose();
    super.dispose();
  }

  List<String> buttonsList = [
    'C', '(', ')', '/',
    '7', '8', '9', '*',
    '4', '5', '6', '+',
    '1', '2', '3', '-',
    'AC', '0', '.', '=',
  ];

  List<String> keyboardList = [
    'Enter', 'Numpad Multiply', 'Numpad Subtract',
    'Numpad Add'
  ];

  @override
  Widget build(BuildContext context) {

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Calculator'),
          actions: [
            IconButton(
              icon: Icon(Icons.brightness_6, size: 32,),
              onPressed: () => themeProvider.toggleTheme(),
              tooltip: "toggle darkmode",
            ),
            Builder(
              builder: (context) {
                return IconButton(
                  icon: Icon(Icons.history, size: 32),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  tooltip: "view history",
                );
              }
            ),
          ],
        ),
        drawer: Drawer(
          child: HistoryPanel(history: calculationHistory),
        ),
        body: KeyboardListener(
          focusNode: _focuseNode,
          onKeyEvent: (KeyEvent event) {
            handleKeyEvent(event);
          },
          child: SizedBox(
            child: Scaffold(
              body: Column(
                children: [
                  Flexible(child: resultsWidget(), flex: 1),
                  Flexible(child: buttonsWidget(), flex: 3),
                ],
              ),
            ),
          ),
        )
      ),
    );
  }

  void handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      // print(event);
      final logicalKey = event.logicalKey;
      String modifiedInput = checkKeyboardInput(logicalKey.keyLabel);
      if (_isValidInput(modifiedInput)) {
        setState(() {
          handleButtonPress(modifiedInput);
        });
      }
    }
  }
  bool _isValidInput(String input) {
    final validInputs = buttonsList;

    return validInputs.contains(input);
  }

  String checkKeyboardInput(String input) {
    Map<String, String> numpadToCalculator = {
      "Numpad Multiply": "*",
      "Numpad Add": "+",
      "Numpad Subtract": "-",
      "Numpad Divide": "/",
      "Enter": "=",
      "Numpad 0": "0",
      "Numpad 1": "1",
      "Numpad 2": "2",
      "Numpad 3": "3",
      "Numpad 4": "4",
      "Numpad 5": "5",
      "Numpad 6": "6",
      "Numpad 7": "7",
      "Numpad 8": "8",
      "Numpad 9": "9",
      "Backspace": "C",
      ",": ".",
    };
    return numpadToCalculator[input] ?? input;
  }

  Widget resultsWidget() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.centerRight,
          child: Text(
            userInput,
            style: const TextStyle(fontSize: 25),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.centerRight,
          child: Text(
            result,
            style: const TextStyle(fontSize: 70, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget buttonsWidget() {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: buttonsList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height * 0.56),
      ),
      itemBuilder: (BuildContext context, int index) {
        return button(buttonsList[index]);
      },
    );
  }


  Widget button(String text) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: MaterialButton(
        onPressed: () {
          setState(() {
            handleButtonPress(text);
          });
        },
        color: getColor(text),
        textColor: Colors.white,
        child: Text(
          text,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  handleButtonPress(String text){

    if(text=="AC"){
      //clear all
      userInput = "";
      result = "0";
      return;
    }
    if(text=="C"){
      //remove last input
      userInput = userInput.substring(0, userInput.length -1);
      return;
    }

    if(text=="=" || text=="Enter"){
      //calculate
      result = calculate();
      //.0 check
      if (result.endsWith(".0")) result = result.replaceAll(".0", "");
      if(result != "error"){
        calculationHistory.add('$userInput = $result');
      }
      return;
    }

    //update userinput
    userInput = userInput + text;
  }

  String calculate(){
    try {
      var exp = Parser().parse(userInput);
      var evaluation = exp.evaluate(EvaluationType.REAL, ContextModel());
      return evaluation.toString();
    } catch (e) {
      return "error: $e";
    }
  }

  getColor(String text) {
    if(text == "/" || text == "*" || text == "+" || text == "-"){
      return Colors.deepPurple;
    }
    if(text == "C" || text == "AC"){
      return Colors.red[600];
    }
    if(text == "(" || text == ")"){
      return Colors.lightGreen;
    }
    if(text == "="){
      return Colors.orangeAccent;
    }
    return Colors.lightBlue[600];
  }
}