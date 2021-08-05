import QtQuick 2.0

Item {
    id: root
    property var user: null
    property int index: 0
    signal clicked(var user)
    height: 20
    width:parent.width
    Rectangle{
        anchors.fill: parent
        color: "blue"
        border.width: 1
        border.color: "red"
        Text {
            color:"white"
            id: screenName
            text: user.name
        }

        MouseArea{
            anchors.fill: parent
            onClicked: {
                root.clicked(user)
            }
        }
    }
}
