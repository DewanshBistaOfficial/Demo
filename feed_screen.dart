import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/card.dart';
import '../utils/search.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String keyword = 'all';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CardModel>(
      create: (context) => CardModel(),
      builder: (context, child) {
        CardModel model = Provider.of<CardModel>(context);
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text("Search"),
            actions: [
              IconButton(
                onPressed: () {
                  // method to show the search bar
                  showSearch(
                          context: context,
                          // delegate to customize the search bar
                          delegate: CustomSearchDelegate())
                      .then((value) async {
                    keyword = value;
                    model.keyword = keyword;
                    await model.getImages(keyword: keyword);
                    setState(() {});
                  });
                },
                icon: const Icon(Icons.search),
              )
            ],
          ),
          body: Column(
            children: [
              Text(keyword),
              Text(model.urls.length.toString()),
              Expanded(
                child: SafeArea(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(16),
                    child: _swipeCards(model),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _swipeCards(CardModel model) {
    final urls = model.urls;
    return Stack(
      children: urls
          .map((url) => SwipeCard(
                model: model,
                url: url,
                isTop: urls.last == url,
              ))
          .toList(),
    );
  }
}

class SwipeCard extends StatefulWidget {
  final String url;
  final bool isTop;
  final CardModel model;
  const SwipeCard(
      {Key? key, required this.isTop, required this.url, required this.model})
      : super(key: key);

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(child: widget.isTop ? _topCard() : _swipeCard());
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final size = MediaQuery.of(context).size;
      widget.model.setSize(size);
    });
  }

  Widget _topCard() {
    return GestureDetector(
      child: LayoutBuilder(
        builder: (context, constraints) {
          int milliseconds = widget.model.isDragging ? 0 : 500;
          final angle = widget.model.angle * pi / 180;
          final center = constraints.smallest.center(Offset.zero);
          final rotationMatrix = Matrix4.identity()
            ..translate(center.dx, center.dy)
            ..rotateZ(angle)
            ..translate(-center.dx, -center.dy);

          return AnimatedContainer(
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: milliseconds),
              transform: rotationMatrix
                ..translate(widget.model.position.dx, widget.model.position.dy),
              child: Stack(
                children: [
                  _swipeCard(),
                  _buildStamps(),
                ],
              ));
        },
      ),
      onPanStart: (details) {
        widget.model.startPan(details);
      },
      onPanUpdate: (details) {
        widget.model.updatePan(details);
      },
      onPanEnd: (details) {
        widget.model.endPan();
      },
    );
  }

  Widget _swipeCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(widget.url), fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildStamps() {
    final status = widget.model.getStatus();
    final opacity = widget.model.getStatusOpacity();

    switch (status) {
      case CardStatus.like:
        final stamp = _buildStamp(
            opacity: opacity, angle: -0.5, color: Colors.green, text: "Yeah");
        return Positioned(top: 64, left: 50, child: stamp);
      case CardStatus.dislike:
        final stamp = _buildStamp(
            opacity: opacity, angle: .5, color: Colors.red, text: "Nah");
        return Positioned(top: 64, right: 50, child: stamp);
      case CardStatus.superlike:
        final stamp =
            _buildStamp(opacity: opacity, color: Colors.yellow, text: "Meh");
        return Center(child: stamp);
      default:
        return Container();
    }
  }

  Widget _buildStamp({
    double angle = 0,
    required double opacity,
    required Color color,
    required String text,
  }) {
    return Opacity(
      opacity: opacity,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 4),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: color, fontSize: 48, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
