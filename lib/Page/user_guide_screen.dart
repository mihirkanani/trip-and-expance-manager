import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:flutter/material.dart';

class UserGuide extends StatelessWidget {
  const UserGuide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: ColorConstant.primaryColor),
                  ),
                ),
                // color: Colors.white,
                child: Text(
                  "Usage Guide",
                  style: TextStyleConstant.blackBold16.copyWith(fontSize: 18),
                )),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Icon(Icons.blur_circular_outlined),
                SizedBox(
                  width: 15,
                ),
                Text(
                  "Daily Expense Manager",
                  style: TextStyleConstant.blackBold16.copyWith(fontSize: 18),
                )
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "Add your income and expense on daily basis and you can see your remaining balance after deduction of expense from total income on dashboard.\n",
              textAlign: TextAlign.justify,
            ),
            Text(
              "You can Add income or expense by category and with adding images regarding that.\nYou can also add your own category in category screen.\n",
              textAlign: TextAlign.justify,
            ),
            Text(
              "There is an option to analyze your expense by filtering and using graph.",
              textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Icon(Icons.blur_circular_outlined),
                SizedBox(
                  width: 15,
                ),
                Text(
                  "Trip Expense Manager",
                  style: TextStyleConstant.blackBold16.copyWith(fontSize: 18),
                )
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "This is very useful feature to manage our trip expense over multipe users.\n",
              textAlign: TextAlign.justify,
            ),
            Text(
              "There will be different category for ongoing and past trips on home screen.\nYou can create new trip with image,date of trip,adding trip name and place and no of users involved in trip.\n",
              textAlign: TextAlign.justify,
            ),
            Text(
              "Expenses can be added by user wise and it will be caluculates and displayed on trip info page.\nTotal expense is divided into perhead expense as per users so we can manage expense at the end of trip. ",
              textAlign: TextAlign.justify,
            )
          ],
        ),
      ),
    );
  }
}
