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

    function deleteAt(index){
        const plainText = txtPlain.getText(0,500)
        console.debug("deleting at")

        var rawText = ""
        txtPlain.text.replace(/<p(?: [^>]*)?>(.*?)<\/p>/,(elm,inside)=>{
            rawText = inside
        })
        console.log(rawText)
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

    function breakLink(index, relativeIndex, mainPos){
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
                    return "@"+ inside
                }
                return elm
        })
        txtPlain.text = ats + " "
        txtPlain.cursorPosition = mainPos
        pushBeginBack()
    }

    function pushBeginBack(spaces = 1){
        allAts = allAts.map((elm)=>{
            if(txtPlain.cursorPosition<elm.begin){
                const newElm = elm
                newElm.begin -= spaces
                return newElm
            }
            return elm
        })
    }


    function findWordIndexOfCursor(words, cursorPosition){
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
                    const rawText = txtPlain.text.match(/<p(?: [^>]*)?>(.*?)<\/p>/)[0]
                    console.debug(`Cursor Position === ${txtPlain.cursorPosition}`)
                    allAts.forEach((elm,idx)=>{
                        if(elm.begin+elm.length === txtPlain.cursorPosition){
                            deleteAt(idx)
                        }else if(elm.begin <= txtPlain.cursorPosition && elm.begin+elm.length >= txtPlain.cursorPosition){
                           console.debug("Should break link")
                           breakLink(idx,txtPlain.cursorPosition-elm.begin, txtPlain.cursorPosition)
                        }
                    })
                }
            }

            // /@<span(?: [^>]*)?>(.*?)<\/span>/g
            onTextChanged: {
                var words = getText(0,500).split(" ") //Splits the text into an array of words
                totalWords = words.length
                allAts.forEach(elm=>{
                    console.debug(`${elm.text} \n Begin: ${elm.begin} --- End:${elm.begin+elm.length}`)
                })
                console.debug(allAts.length)
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
