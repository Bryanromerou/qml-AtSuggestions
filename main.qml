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

    function createSearchResult (user,idx){
            var component = Qt.createComponent("SearchResult.qml")
            searchResultsElm.push(component.createObject(suggestionsColm,{"user":user,"index":idx}))
    }
    function clearSearchResultElm (){
        searchResultsElm.forEach((elm)=>{
            elm.destroy()
        })
        searchResultsElm = []
    }

    function addSpecialText(originalText){
        return `${originalText}`
    }

    Column{
        id:cols
        anchors.fill: parent
        anchors.margins: 5
        spacing: 3
        topPadding: 100

        Rectangle{
            id:suggestions
            width: frame.width
            height: 200
            color: txtPlain.atFlag ? "red" : "transparent"
            Column{
                id: suggestionsColm
                anchors.fill: parent
                anchors.margins: 5
                spacing: 3
            }
        }

        Rectangle{
            id:frame
            width:parent.width
            height: 25
            border.color: "gray"
            border.width: 1
            radius: 3



            TextInput{
                id:txtPlain
                anchors.fill: parent
                anchors.margins: 4
                property bool atFlag: false
                property int resultSize: 0
                onTextEdited: {
                    var words = text.split(" ")
                    var patt = /^@.*/;
                    var result = words[words.length-1].match(patt);
                    resultSize =  result ? result[0].length : 0
                    atFlag = Boolean(result)
                    if(result){
                        searchResults = []
                        result = result[0].slice(1)
                        console.log(result)
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

                    searchResults.forEach((elm,idx)=>{
                        console.log(`User ${idx+1} found = ${elm.name} and phone number = ${elm.number}`)
                    })
                }
                onAccepted:{
                    if(searchResultsElm){
                        console.log(resultSize)
                        text = text.slice(0,text.length-resultSize+1) + addSpecialText(searchResults[0].name) + " "
                        clearSearchResultElm()
                        txtPlain.atFlag = false
                    }
                }
            }
//            Text{
//                id:textShow
//                text:txtPlain.text
//            }
        }
    }
}
