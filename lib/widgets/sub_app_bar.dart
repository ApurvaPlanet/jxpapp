import 'package:flutter/material.dart';

class SubAppBar extends StatelessWidget {
  final String pageTitle;
  final bool showBackBtn; // Back button visibility

  const SubAppBar({
    Key? key,
    required this.pageTitle,
    this.showBackBtn = false, // Default value
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Column(
    //   mainAxisSize: MainAxisSize.min, // Ensures it only takes needed height
    //   children: [
    //     // Client & Asset Name Display
    //     Container(
    //       padding: const EdgeInsets.all(10),
    //       alignment: Alignment.centerLeft,
    //       child: const Text(
    //         'Client Name Display here | Asset Name Display here',
    //         style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    //       ),
    //     ),
    //
    //     // App Bar with Background
    //     SizedBox(
    //       height: 60,
    //       width: double.infinity,
    //       child: Stack(
    //         alignment: Alignment.centerLeft,
    //         children: [
    //           // Background Image
    //           Positioned.fill(
    //             child: Image.asset(
    //               'assets/AppBarBG.png',
    //               fit: BoxFit.cover,
    //             ),
    //           ),
    //
    //           // Dark Overlay
    //           Positioned.fill(
    //             child: Container(
    //               color: Colors.black.withOpacity(0.3),
    //             ),
    //           ),
    //
    //           // Back Button (Optional)
    //           if (showBackBtn)
    //             Positioned(
    //               left: 10,
    //               child: IconButton(
    //                 icon: const Icon(Icons.arrow_back_outlined, color: Colors.white, size: 30),
    //                 onPressed: () => Navigator.pop(context),
    //               ),
    //             ),
    //
    //           // Page Title
    //           Padding(
    //             padding: EdgeInsets.symmetric(horizontal: showBackBtn ? 50 : 10),                child: Text(
    //             pageTitle,
    //             style: const TextStyle(
    //               fontSize: 20,
    //               fontWeight: FontWeight.bold,
    //               color: Colors.white,
    //             ),
    //           ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ],
    // );
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/AppBarBG.png',
              fit: BoxFit.cover,
            ),
          ),

          // Dark Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),

          // Back Button (Optional)
          if (showBackBtn)
            Positioned(
              // left: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_outlined, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),

          // Page Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: showBackBtn ? 50 : 10),                child: Text(
            pageTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          ),
        ],
      ),
    );
  }
}
