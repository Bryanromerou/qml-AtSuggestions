import QtQuick 2.0

Item {
    id: root
    property var user: null
    property int index: 0
    signal clicked(var user, var index)
    height: 40
    width:parent.width
    Rectangle{
        anchors.fill: parent
        color: "gray"
        border.width: 1
//        border.color: "red"
        Text {
            color:"white"
            id: screenName
            text: user.name
        }
        Text {
            id: number
            text: user.number
            anchors.top: screenName.bottom
        }

        MouseArea{
            anchors.fill: parent
            onClicked: {
                root.clicked(user,index)
            }
        }
    }
}
