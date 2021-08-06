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

    function searchElmClicked( user, index)
    {
        console.debug(`${user.name} has been clicked and their index is ${index}`);
        txtPlain.text = txtPlain.text.slice(0,txtPlain.text.length-txtPlain.resultSize+1) + addSpecialText(searchResults[index].name) + " "
        clearSearchResultElm()
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

    function addSpecialText(originalText){
        return `${originalText}`
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
        height: 25
        border.color: "gray"
        border.width: 1
        radius: 3

        TextInput{
            id:txtPlain
            selectedTextColor: "transparent"
            anchors.fill: parent
            anchors.margins: 4
            property bool atFlag: false
            property int resultSize: 0
            color: "black"
            onTextEdited: {
                var words = text.split(" ") //Splits the text into an array of words
                var result = words[words.length-1].match(/^@.*/); // Saves the last @ to result
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
            onAccepted:{
                if(searchResultsElm){
                    console.log(resultSize)
                    text = text.slice(0,text.length-resultSize+1) + addSpecialText(searchResults[0].name) + " "
                    clearSearchResultElm()
                    txtPlain.atFlag = false
                    txtPlain.focus = true
                    txtPlain.color = "black"
                }
            }
        }
    }

}
