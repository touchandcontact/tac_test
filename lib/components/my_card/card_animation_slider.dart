import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';

import '../../models/app_user_card.dart';

class CardAnimationSlider extends StatefulWidget {
  List<AppUserCard> listCard;
  int indexSelectedCard;
  Function(AppUserCard? userCard) onChangeCard;
  Function(int idCard) onDeleteCard;

  CardAnimationSlider(
      {Key? key,
      required this.listCard,
      required this.onChangeCard,
      this.indexSelectedCard = 0,
      required this.onDeleteCard})
      : super(key: key);

  @override
  State<CardAnimationSlider> createState() => _CardAnimationSliderState();
}

class _CardAnimationSliderState extends State<CardAnimationSlider> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: widget.listCard.length == 1 ? 200 : 300,
        child: Swiper(
          index: widget.indexSelectedCard,
          itemCount: widget.listCard.length,
          itemHeight: 200,
          itemWidth: MediaQuery.of(context).size.width,
          scrollDirection: Axis.vertical,
          layout: widget.listCard.length == 1
              ? SwiperLayout.DEFAULT
              : SwiperLayout.STACK,
          onIndexChanged: (int index) {
            widget.onChangeCard(widget.listCard[index]);
          },
          itemBuilder: (context, index) {
            final cardObj = widget.listCard[index];
            return Container(
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: cardObj.frontImage == null ||
                                cardObj.frontImage!.isEmpty
                            ? const AssetImage("assets/images/card_default_image.png")
                                as ImageProvider
                            : NetworkImage(cardObj.frontImage!))),
                child: Container(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.more_horiz, color: Colors.white),
                    onPressed: () {
                      widget.onDeleteCard(cardObj.id);
                    },
                  ),
                ));
          },
        ));
  }
}
