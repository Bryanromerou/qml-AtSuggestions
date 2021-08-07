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
    property int key: 0

    function searchElmClicked( user, index)
    {
        const plainText = txtPlain.getText(0,500)
        const croppedText = plainText.slice(0,plainText.length-txtPlain.resultSize+1)
        const regularText = searchResults[index].name
        const specialText = addSpecialText(regularText)

        allAts.push({
            "begin":croppedText.length-1,
            "length": regularText.length + 1,
            "text": regularText,
            "key": key,
            "wordIdx": wordIdx,
            "wordCount": user.name.split(" ").length
        })

        txtPlain.text = croppedText + specialText + " "
        clearSearchResultElm()
        txtPlain.cursorPosition = txtPlain.getText(0,500).length
        key += 1
        colorText()
        txtPlain.atFlag = false
    }

    function createSearchResult (user,idx){
        var component = Qt.createComponent("SearchResult.qml")
        var temp = component.createObject(suggestionsColm,{"user":user,"index":idx})
        temp.clicked.connect(searchElmClicked)
        suggestions.height = suggestions.height + 25
        searchResultsElm.push(temp)
    }
    function clearSearchResultElm (){
        searchResultsElm.forEach((elm)=>{
            elm.destroy()
        })
        suggestions.height = 0
        searchResultsElm = []
    }
    function colorText(finalCursorPosition = null){
        let tempText = ""
        const wordArr = txtPlain.getText(0,500).split(" ")
        const newWordArr = []
        wordArr.forEach((word,idx)=>{
            let tempWord = word
            let skip = false
            allAts.forEach((elm)=>{
                if( elm.wordIdx === idx)
                    tempWord = "@" + addSpecialText(elm.text)
                else if(elm.wordIdx+elm.wordCount-1 >= idx && elm.wordIdx < idx)
                    skip = true
            })
            if(!skip)
                newWordArr.push(tempWord)
        })
        console.log(newWordArr.join(" "))
        txtPlain.text = newWordArr.join(" ")
        txtPlain.cursorPosition = txtPlain.getText(0,500).length
    }

    function addSpecialText(originalText){
        return `<font color=\"#0000FF\">${originalText}</font>`
    }

    function deleteAt(element){
        const plainText = txtPlain.getText(0,500)
        const wordArr = plainText.split(" ")
        wordArr.forEach((elm,idx)=>{
            console.debug(`1.) ${elm}`)
        })
        wordArr.splice(element.wordIdx,element.wordCount)
        wordArr.forEach((elm,idx)=>{
            console.debug(`2.) ${elm}`)
        })
        console.debug(wordArr.join(" "))
        txtPlain.text = wordArr.join(" ")
        allAts = allAts.filter((at) => at.key !== element.key)
        console.debug(element.begin)
        colorText(element.begin)
    }

    function findWordIndexOfCursor(words, cursorPosition){
        const plainText = txtPlain.getText(0,500)

        let newCursorPosition = cursorPosition
        for(let i=0;i<cursorPosition; i++){
            if (plainText[i]===" ")
                newCursorPosition -= 1
        }
//        console.debug(`Cursor Position WITH whitespaces ${cursorPosition}`)
//        console.debug(`Cursor Position without the whitespaces ${newCursorPosition}`)
        let letterCount = 0
        let returnIndex = -1
        words.forEach((elm,idx)=>{
            if(newCursorPosition > letterCount && newCursorPosition<=letterCount+elm.length){
//                console.debug(`The word your touching is ${elm} and the position is ${idx}`)
                returnIndex = idx
            }
            letterCount += elm.length
        })
        return returnIndex
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
                if(event.key === 16777219){
                    allAts.forEach((elm)=>{
                        if(elm.begin+elm.length === txtPlain.cursorPosition){
                            deleteAt(elm)
                        }
                    })
                }
            }
            onTextChanged: {
                console.debug(getText(0,500))
                var words = getText(0,500).split(" ") //Splits the text into an array of words
                totalWords = words.length
                var result = words[words.length-1].match(/^@.*/); // Saves the last @ to result
                wordIdx = findWordIndexOfCursor(words,txtPlain.cursorPosition);
                resultSize =  result ? result[0].length : 0
                atFlag = Boolean(result)
                if(result){
                    searchResults = []
                    result = result[0].slice(1)

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
