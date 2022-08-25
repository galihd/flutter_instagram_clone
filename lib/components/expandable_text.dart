import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  ExpandableText({Key? key, required this.text, required this.displayLength, this.leadingText}) : super(key: key);
  String? leadingText;
  final String text;
  final int displayLength;
  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  late String displayText;
  late String expandText;
  bool expanded = false;
  @override
  void initState() {
    // TODO: implement initState
    if (widget.displayLength > widget.text.length) {
      displayText = widget.text;
      expandText = "";
    } else {
      displayText = widget.text.substring(0, widget.displayLength);
      expandText = widget.text.substring(widget.displayLength, widget.text.length);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: widget.leadingText == null
          ? expandText.isEmpty
              ? Text(displayText, maxLines: 2)
              : expanded
                  ? Text(widget.text, maxLines: null)
                  : Wrap(children: [
                      Text("$displayText... "),
                      GestureDetector(
                          onTap: () => setState(() {
                                expanded = !expanded;
                              }),
                          child: Text(
                            'Read more',
                            style: TextStyle(color: Colors.blue.shade400),
                          ))
                    ])
          : RichText(
              text: TextSpan(
                text: '${widget.leadingText} ',
                style: Theme.of(context).textTheme.bodyMedium!.merge(const TextStyle(fontWeight: FontWeight.w700)),
                children: [
                  if (expandText.isEmpty) TextSpan(text: displayText, style: Theme.of(context).textTheme.bodyMedium!),
                  if (expandText.isNotEmpty)
                    if (!expanded)
                      TextSpan(text: '$displayText... ', style: Theme.of(context).textTheme.bodyMedium!, children: [
                        TextSpan(
                            text: 'Show more',
                            style: Theme.of(context).textTheme.bodyText1!.merge(TextStyle(color: Colors.blue.shade700)),
                            recognizer: TapGestureRecognizer()..onTap = () => setState(() => expanded = !expanded))
                      ])
                    else
                      TextSpan(text: widget.text, style: Theme.of(context).textTheme.bodyMedium!)
                ],
              ),
              softWrap: true,
            ));
}
