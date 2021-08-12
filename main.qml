import QtQuick 2.12
import QtQuick.Window 2.12

Window {
    id:root
    width: 375
    height: 832
    visible: true

    signal activated ()
    readonly property var users: [
      {
            name:"Lilly",
            number:"+13122593776"
      },
      {
            name:"Issac",
            number:"+19179926276"
      },
      {
            name:"Sunil",
            number:"+6591654067"
      },
      {
            name:"Bryan Romero",
            number:"+13233971418"
      },
      {
            name:"Romeo Sunshine",
            number:"+13271891468"
      },
      {
            name: "Leoh",
            number:"+5493755674135"
      },
      {
            name:"Ishod Ware",
            number:"+135269715384"
      }
    ]
    property var searchResults: []
    property var searchResultsElm: []
    property var allAts: []
    property int wordIdx: 0
    property int totalWords: 0
    property string currText: ""
    property int lastPos: 0


    function searchElmClicked( user, index) // Click listener for when a suggetion is clicked.
    {
        const plainText = txtPlain.getText(0,500)
        const words = plainText.split(" ")
        const croppedText = plainText.slice(0,plainText.length-txtPlain.resultSize+1)
        const regularText = searchResults[index].name
        const specialText = addSpecialText(regularText)

        const insertPos = findWordIndexOfCursor(words,txtPlain.cursorPosition)

        var rawText = ""
        var count = 0
        txtPlain.text.replace(/<p(?: [^>]*)?>(.*?)<\/p>/,(elm,inside)=>{
            rawText = inside
        })

        const tempAts = {}

        var newText = rawText.replace(/<span(?: [^>]*)?>(.*?)<\/span>/g,(elm,inside)=>{
                count += 1
                tempAts[`temp${count}`] = elm
                return `temp${count}`
        })
        console.debug(newText)
        count = 0
        const newWords = newText.split(" ")



        let updatedText = ""
        var skip = 0

        newWords.forEach((elm,idx)=>{
            if(idx === insertPos){
                updatedText += "@" + specialText
            }else{
                updatedText += elm
            }
            updatedText += " "
        })

        updatedText = updatedText.replace(/(temp)\w+/g,(elm,inside)=>{
            count += 1
            return tempAts[`temp${count}`]
        })

        console.debug(updatedText)

        allAts.push({
            "begin":txtPlain.cursorPosition-txtPlain.resultSize,
            "length": regularText.length + 1,
            "text": regularText,
            "wordIdx": wordIdx,
            "wordCount": user.name.split(" ").length
        })

        txtPlain.text = updatedText
        clearSearchResultElm()
        txtPlain.cursorPosition = txtPlain.getText(0,500).length
        txtPlain.atFlag = false
    }

    function createSearchResult (user,idx){// Creates a user suggestion element/component
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
        pushBeginBack()
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
//        console.debug("pushing the begin forward")
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
//        console.debug(`Before == "${plainText[cursorPosition]}" and After == "${plainText[cursorPosition]}"`)
//        if (plainText[cursorPosition] === " " && plainText[cursorPosition] === " " ){
//            return " "
//        }
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
            color: "black"
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
//                var result = findWordTouchingCursor(txtPlain.getText(0,500).split(" "),txtPlain.cursorPosition);
//                atFlag = result[0] === "@"
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
//                allAts.forEach(elm=>{
//                    console.debug(`${elm.text} \n Begin: ${elm.begin} --- End:${elm.begin+elm.length}`)
//                })

                var result = findWordTouchingCursor(words,txtPlain.cursorPosition);
                atFlag = result[0] === "@"
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
                                var new_pattern = new RegExp("^("+ result.toLowerCase() +").*")
                                const match = name.toLowerCase().match(new_pattern)
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
