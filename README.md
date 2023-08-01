# flow_board

<h1 align="center"><b>Flow Board</b></h1>

<p align="center">A customizable and draggable Kanban Board widget for Flutter</p>

## Intro

flow_board is a customizable and draggable Kanban Board widget for Flutter.
You can use it to create a Kanban Board tool like those in Trello.

Check out [flow_board](https://github.com/zuhabul/flow_board) to see to build a BoardView database.

## Getting Started

Add the FlowBoard [Flutter package](https://docs.flutter.dev/development/packages-and-plugins/using-packages) to your environment.

With Flutter:

```dart
flutter pub add flow_board
flutter pub get
```

This will add a line like this to your package's pubspec.yaml:

```dart
dependencies:
  flow_board: ^0.0.1
```

## Create your first board

Initialize an `FlowBoardController` for the board. It contains the data used by the board. You can
register callbacks to receive the changes of the board.

```dart

final FlowBoardController controller = FlowBoardController(
  onMoveGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
    debugPrint('Move item from $fromIndex to $toIndex');
  },
  onMoveGroupItem: (groupId, fromIndex, toIndex) {
    debugPrint('Move $groupId:$fromIndex to $groupId:$toIndex');
  },
  onMoveGroupItemToGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
    debugPrint('Move $fromGroupId:$fromIndex to $toGroupId:$toIndex');
  },
);
```

Provide an initial value of the board by initializing the `FlowBoardGroupData`. It represents a group data and contains list of items. Each item displayed in the group requires to implement the `FlowBoardGroupItem` class.

```dart

void initState() {
  final group1 = FlowBoardGroupData(id: "To Do", items: [
    TextItem("Card 1"),
    TextItem("Card 2"),
  ]);
  final group2 = FlowBoardGroupData(id: "In Progress", items: [
    TextItem("Card 3"),
    TextItem("Card 4"),
  ]);

  final group3 = FlowBoardGroupData(id: "Done", items: []);

  controller.addGroup(group1);
  controller.addGroup(group2);
  controller.addGroup(group3);
  super.initState();
}

class TextItem extends FlowBoardGroupItem {
  final String s;
  TextItem(this.s);

  @override
  String get id => s;
}

```

Finally, return a `FlowBoard` widget in the build method.

```dart

@override
Widget build(BuildContext context) {
  return FlowBoard(
    controller: controller,
    cardBuilder: (context, group, groupItem) {
      final textItem = groupItem as TextItem;
      return FlowBoardGroupCard(
        key: ObjectKey(textItem),
        child: Text(textItem.s),
      );
    },
    groupConstraints: const BoxConstraints.tightFor(width: 240),
  );
}

```

## Usage Example

To quickly grasp how it can be used, look at the /example/lib folder.
First, run main.dart to play with the demo.

Second, let's delve into multi_board_list_example.dart to understand a few key components:

* A Board widget is created via instantiating an `FlowBoard` object.
* In the `FlowBoard` object, you can find the `FlowBoardController`, which is defined in board_data.dart, is fed with pre-populated mock data. It also contains callback functions to materialize future user data.
* Three builders: FlowBoardHeaderBuilder, FlowBoardFooterBuilder, FlowBoardCardBuilder. See below image for what they are used for.

## Glossary

Please refer to the API documentation.

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.

## Acknowledgements

This package is a modified version of the [appflowy-board](https://pub.dev/packages/appflowy_board). You can find the original package's license [here](https://github.com/AppFlowy-IO/appflowy-board/blob/main/LICENSE).

## License

This package is distributed under the terms of the MIT License. See the [LICENSE](LICENSE) file for details.

