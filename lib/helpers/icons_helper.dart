import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tac/models/icon_item.dart';

IconData getLinkIconFromString(String value) {
  switch (value.toLowerCase()) {
    case "facebook":
      return Icons.facebook;
    case "whatsapp":
      return FontAwesomeIcons.whatsapp;
    case "instagram":
      return FontAwesomeIcons.instagram;
    case "linkedin":
      return FontAwesomeIcons.linkedin;
    case "snapchat":
      return Icons.snapchat;
    case "tiktok":
      return Icons.tiktok;
    case "github":
      return FontAwesomeIcons.github;
    case "spotify":
      return FontAwesomeIcons.spotify;
    case "soundcloud":
      return FontAwesomeIcons.soundcloud;
    case "youtube":
      return FontAwesomeIcons.youtube;
    case "trello":
      return FontAwesomeIcons.trello;
    case "slack":
      return FontAwesomeIcons.slack;
    case "twitter":
      return FontAwesomeIcons.twitter;
    case "telegram":
      return Icons.telegram;
    default:
      return Icons.link;
  }
}

IconData getDocumentIconFromString(String value) {
  switch (value.toLowerCase()) {
    case "powerpoint":
      return FontAwesomeIcons.filePowerpoint;
    case "excel":
      return FontAwesomeIcons.fileExcel;
    case "word":
      return FontAwesomeIcons.fileWord;
    case "image":
      return FontAwesomeIcons.fileImage;
    case "pdf":
      return FontAwesomeIcons.filePdf;
    case "zipper":
      return FontAwesomeIcons.fileZipper;
    default:
      return FontAwesomeIcons.file;
  }
}

List<IconItem> getLinkAvailableIcons() {
  return <IconItem>[
    IconItem(icon: Icons.link, name: "Custom Link"),
    IconItem(icon: Icons.facebook, name: "Facebook"),
    IconItem(icon: FontAwesomeIcons.whatsapp, name: "Whatsapp"),
    IconItem(icon: FontAwesomeIcons.instagram, name: "Instagram"),
    IconItem(icon: FontAwesomeIcons.linkedin, name: "Linkedin"),
    IconItem(icon: Icons.snapchat, name: "Snapchat"),
    IconItem(icon: Icons.tiktok, name: "TikTok"),
    IconItem(icon: FontAwesomeIcons.github, name: "GitHub"),
    IconItem(icon: FontAwesomeIcons.spotify, name: "Spotify"),
    IconItem(icon: FontAwesomeIcons.soundcloud, name: "SoundCloud"),
    IconItem(icon: FontAwesomeIcons.youtube, name: "YouTube"),
    IconItem(icon: FontAwesomeIcons.trello, name: "Trello"),
    IconItem(icon: FontAwesomeIcons.slack, name: "Slack"),
    IconItem(icon: FontAwesomeIcons.twitter, name: "Twitter"),
    IconItem(icon: Icons.telegram, name: "Telegram")
  ];
}
