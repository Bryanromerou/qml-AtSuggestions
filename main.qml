import QtQuick 2.12
import QtQuick.Window 2.12

Window {
    id:root
    width: 375
    height: 832
    visible: true

    signal activated ()
    readonly property var users: [// Temporary Dummy Data
      {
            name:"Lilly",
            description:"Lilly",
            number:"+13122593776"
      },
      {
            name:"Issac",
            description:"Isaac",
            number:"+19179926276"
      },
      {
            name:"Sunil",
            description:"Sunil",
            number:"+6591654067"
      },
      {
            name:"Bryan Romero",
            description:"BryanRomero",
            number:"+13233971418"
      },
      {
            name:"Romeo Sunshine",
            description:"RomeoSunshine",
            number:"+13271891468"
      },
      {
            name: "Leoh",
            description:"Leoh",
            number:"+5493755674135"
      },
      {
            name:"Ishod Ware",
            description:"IshodWare",
            number:"+135269715384"
      }
    ]
    property var searchResults: [] // Hold the actual user information from the suggestions
    property var searchResultsElm: [] //Holds the user element that is displayed to the user to pick on
    property var allAts: [] // Array of @ that already exist in the TextInput, Example: { begin:0, length:4, text:"Ana", wordIdx:0, wordCount:1 } -- @Ana
    property int wordIdx: 0 // Stores the word Index of where the cursor is currently touching
    property int totalWords: 0 // Hold the number of total words
    property string currText: ""
    property int lastPos: 0 // Stores the last position of the cursor - to keep track of changes in cursor position


    function searchElmClicked(user, index){ // Click listener for when a suggetion is clicked. -- Adds the user to allAts and sorts allAts by their begining
        const plainText = txtPlain.getText(0,500) //This variable shall hold all of the text inside of TextInput NOT INCLUDNING spans
        const words = plainText.split(" ")
        const croppedText = plainText.slice(0,plainText.length-txtPlain.resultSize+1) // So if text is "hey @bry" croppedText is "hey @"
        const regularText = searchResults[index].name // regularText hold the whole name of the person who they clicked on
        const insertPos = findWordIndexOfCursor(words,txtPlain.cursorPosition) // Finds the word index of where the cursor currently e.i. ("hey my name| is bryan", insertPos == 2) ; ("hey my| name is bryan", insertPos == 1)

        let updatedText = ""
        words.forEach((elm,idx)=>{// Loops through every word and will add the new @
            if(idx === insertPos){
                updatedText += regularText
            }else{
                updatedText += elm
            }
            updatedText += " "
        })

        allAts.push({
            "begin":lastPos-txtPlain.resultSize,
            "length": regularText.length + 1,
            "text": regularText,
            "wordIdx": wordIdx,
            "wordCount": user.name.split(" ").length
        })
        allAts.sort((elmA,elmB)=>{
            return elmA.begin - elmB.begin
        })

        pushBeginForwards(regularText.length - txtPlain.resultSize +1)
        txtPlain.text = updatedText
        clearSearchResultElm()
        txtPlain.cursorPosition = txtPlain.getText(0,500).length
        colorText()
        txtPlain.atFlag = false
    }

    function createSearchResult (user, idx){// Creates a user suggestion element/component
        var component = Qt.createComponent("SearchResult.qml")
        var temp = component.createObject(suggestionsColm,{"user":user,"index":idx})
        temp.clicked.connect(searchElmClicked)
        suggestions.height = suggestions.height + 25
        searchResultsElm.push(temp)
    }

    function clearSearchResultElm (){ // Function Closes Suggestion Menu
        searchResultsElm.forEach((elm)=>{
            elm.destroy()
        })
        suggestions.height = 0
        searchResultsElm = []
    }

    function colorText(finalCursorPosition = null){ // Function loops through each word and if word has an index that is also inside of allAts array.
        const plainText = txtPlain.getText(0,500)

        allAts.forEach(elm=>{
            console.debug(`${elm.text} \n Begin: ${elm.begin} --- End:${elm.begin+elm.length}`)
        })

        let finalText = ""
        let isAt = false
        let letterCount = 0
        let currAt = ""
        for(let i = 0; i<plainText.length;i++){
            allAts.forEach(elm=>{
                if(elm.begin === i){
                    isAt = true
                    letterCount = elm.length - 1
                    currAt = elm.text
                }
            })
            if(letterCount<1)
                finalText += plainText[i]
            else{
                if(isAt){
                    isAt = false
                    const specialText =
                    finalText += "@" + addSpecialText(currAt) + " "
                }else
                    letterCount -= 1
            }
        }

        txtPlain.text = finalText +" "
        txtPlain.cursorPosition = txtPlain.getText(0,500).length
    }

    function addSpecialText(originalText){ // Function takes in string and returns string back with color span tag
        return `<span style="color:#0000FF;">${originalText}</span>`
    }

    function deleteAt(index){ // Function removes the @ at certain index, corresponding to the allAts array from the TextInput
        const plainText = txtPlain.getText(0,500)
        var rawText = ""
        txtPlain.text.replace(/<p(?: [^>]*)?>(.*?)<\/p>/,(elm,inside)=>{
            rawText = inside
        })
        var count = 0
        var popped = false
        const ats = rawText.replace(/@<span(?: [^>]*)?>(.*?)<\/span>/g,(elm,inside)=>{
                count += 1
                if (index === count-1 && !popped){
                    popped = true
                    allAts.splice(count-1,1)
                    pushBeginBack(inside.length+2)
                    return ''
                }
                return elm
        })
        txtPlain.text = ats + "+"
        txtPlain.cursorPosition = txtPlain.getText(0,500).length
    }

    function breakLink(index, relativeIndex, mainPos){ // Function removes @ from stack if it notices a backspace in any of the @.
        var rawText = ""
        txtPlain.text.replace(/<p(?: [^>]*)?>(.*?)<\/p>/,(elm,inside)=>{
            rawText = inside
        }) // We are using this method vs .getText such that the rawText also includes the spans
        var count = 0 // Keep track of the count so that we can remove the @ by index
        var popped = false

        const ats = rawText.replace(/@<span(?: [^>]*)?>(.*?)<\/span>/g,(elm,inside)=>{
                count += 1
                if (index === count-1 && !popped){
                    popped = true
                    allAts.splice(count-1,1) // Removes @ from "allAts" array
                    return "@"+ inside
                }
                return elm
        })
        txtPlain.text = ats + " "
        txtPlain.cursorPosition = mainPos
    }

    function breakLinkWithAddition(index, relativeIndex, mainPos){ // [WIP] Function should break the link if the user inputs anything inside of an existing @
        }

    function pushBeginBack(spaces = 1){ // Function pushes back the "begin" property for any @ that has their begining before the currentCursor.
        allAts = allAts.map((elm)=>{
            if(lastPos<elm.begin){
                const newElm = elm
                newElm.begin -= spaces
                return newElm
            }
            return elm
        })
    }

    function pushBeginForwards(spaces = 1){ // Function pushes forward the "begin" property for any @ that has their begining before the currentCursor.
        allAts = allAts.map((elm)=>{
            if(lastPos<elm.begin){
                const newElm = elm
                newElm.begin += spaces
                return newElm
            }
            return elm
        })
    }

    function findWordIndexOfCursor(words, cursorPosition){ // Function returns the index of the word which the cursor is touching in respect of all of the words in the input.
        const plainText = txtPlain.getText(0,500)

        let newCursorPosition = cursorPosition
        for(let i=0;i<cursorPosition; i++){
            if (plainText[i]===" ")
                newCursorPosition -= 1
        }

        //New Version to count the word (Buggy)
//        let lastChar = ""
//        let wordCount = 0
//        for(let j=0;j<plainText.length; j++){
//            if(lastChar !== " " && plainText[j] === " " && j < plainText.length-1 && j !== 0){
//                wordCount += 1
//            }
//            lastChar = plainText[j]
//        }
//        console.debug(`Previous === ${returnIndex} ; New === ${wordCount}`)

        let letterCount = 0
        let returnIndex = -1
        words.forEach((elm,idx)=>{
            if(newCursorPosition > letterCount && newCursorPosition<=letterCount+elm.length){
                returnIndex = idx
            }
            letterCount += elm.length
        })
        return returnIndex
    }

    function findWordTouchingCursor(words, cursorPosition){ // Function returns the WORD which the cursor is touching.
        const plainText = txtPlain.getText(0,500)
        let newCursorPosition = cursorPosition

        for(let i=0;i<cursorPosition; i++){
            if (plainText[i]===" " && i<cursorPosition-1)
                newCursorPosition -= 1
        }


        let letterCount = 0
        let returnElm = false
        words.forEach((elm,idx)=>{
            if(newCursorPosition > letterCount && newCursorPosition<=letterCount+elm.length){
                returnElm = elm
            }
            letterCount += elm.length
        })


        return returnElm
    }

    Rectangle{
        id:suggestions
        width: frame.width
        height: 0
        color: txtPlain.atFlag ? "darkgray" : "transparent"
        Column{
            id: suggestionsColm
            anchors.fill: parent
            anchors.margins: 3
        }
        anchors.bottom: frame.top

    }

    Rectangle{
        id:frame
        y:root.height/3
        width:parent.width
        height: txtPlain.contentHeight*1.4
        border.color: "gray"
        border.width: 1
        radius: 3

        TextEdit{
            id:txtPlain
            anchors.fill: parent
            anchors.margins: 4
            property bool atFlag: false
            property int resultSize: 0
            textFormat: TextEdit.RichText
            Keys.onPressed: {
                if(event.key === 16777219){ // 16777219 is the key value for backspace
                    const rawText = txtPlain.text.match(/<p(?: [^>]*)?>(.*?)<\/p>/)[0]
                    allAts.forEach((elm,idx)=>{
                        if(elm.begin+elm.length === txtPlain.cursorPosition){
                            deleteAt(idx)
                        }else if(elm.begin <= txtPlain.cursorPosition && elm.begin+elm.length >= txtPlain.cursorPosition){
                           breakLink(idx,txtPlain.cursorPosition-elm.begin, txtPlain.cursorPosition)
                        }
                    })
                }
            }
            onCursorPositionChanged: {
                lastPos = cursorPosition
            }

            onTextChanged: {
                const textOnly = getText(0,500)
                var words = textOnly.split(" ") //Splits the text into an array of words
                totalWords = words.length
                if(currText<textOnly.length && textOnly.length - currText<= 1)
                    pushBeginForwards()
                else if(currText>textOnly.length && currText - textOnly.length<= 1)
                    pushBeginBack()
                currText = textOnly.length


                var result = findWordTouchingCursor(words,txtPlain.cursorPosition);
                atFlag = result[0] === "@" // If the word that the cursor is touching starts with a @ it sets the atFlag(such that the suggestions menu should pop up)

                wordIdx = findWordIndexOfCursor(words,txtPlain.cursorPosition);
                resultSize =  result ? result.length : 0
                if(atFlag){
                    searchResults = []
                    result = result.slice(1)

                    if(!result)
                        searchResults = users
                    else{
                        users.forEach((user,idx)=>{
                            const names = user.name.split(" ")
                            var addedUser = false
                            names.forEach((name)=>{
                                const match = name.toLowerCase().startsWith(result.toLowerCase())
                                if(match){
                                    if(!addedUser){
                                        addedUser = true
                                        searchResults.push(user)
                                    }
                                }
                            })
                        })
                    }

                    clearSearchResultElm()
                    searchResults.forEach((elm,idx)=>{
                        createSearchResult(elm,idx)
                    })

                }else{
                    searchResults = []
                    clearSearchResultElm()
                }
            }
        }
    }

}
