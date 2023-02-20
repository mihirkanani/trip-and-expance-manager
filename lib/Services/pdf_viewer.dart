import 'dart:io';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/utils/app_utils.dart';
import 'package:expense_manager/utils/image_utils.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfParagraphApi {
  static Future<File> generate({userlist, tripdata, totalEx, totalUser, expenseList, cur, categoryList, catWithSum}) async {
    print(" Expense Summary Total Is $totalUser");
    final ttf = Font.ttf(await rootBundle.load("assets/font/gujarati.ttf"));
    final pdf = Document();
    ByteData personbytes = await rootBundle.load('assets/images/defaultPersonImg.png');
    var buffer = personbytes.buffer;
    ByteData logoByte = await rootBundle.load(ImageConstant.imgICLogo);
    var logoBuffer = logoByte.buffer;
    final customFont = Font.ttf(
      await rootBundle.load('assets/font/poppins/poppins_regular.ttf'),
    );
    pdf.addPage(
      MultiPage(
        build: (context) => <Widget>[
          buildCustomHeader(buffer: buffer),
          buildCustomHeadline(
            data: tripdata,
          ),
          ...buildBulletPoints(
              data: tripdata,
              totalex: totalEx,
              perhead: double.parse((totalEx / totalUser).toString()).toStringAsFixed(2),
              currency: cur,
              customFont: customFont,
              ttf: ttf),

          Header(
              child: pw.Text(
            "Person".toString(),
            style: TextStyle(
              font: ttf,
              color: PdfColors.black,
              fontSize: 22,
              // fontWeight: FontWeight.w600,
            ),
          )),
          userTable(users: userlist, total: totalUser, totalex: totalEx, currency: cur, customFont: customFont, ttf: ttf),
          Header(
              child: pw.Text(
            "Category".toString(),
            style: TextStyle(
              font: ttf,
              color: PdfColors.black,
              fontSize: 22,
              // fontWeight: FontWeight.w600,
            ),
          )),
          categoryExpense(category: categoryList, expense: catWithSum, currency: cur, customFont: customFont, ttf: ttf),
          Header(
              child: pw.Text(
            "Expense".toString(),
            style: TextStyle(
              font: ttf,
              color: PdfColors.black,
              fontSize: 22,
              // fontWeight: FontWeight.w600,
            ),
          )),
          // Text('Expense', style: TextStyle(fontSize: 16))),
          expenseItems(expenseList, currency: cur, ttf: ttf, customFont: customFont),
          // Paragraph(text: LoremText().paragraph(60)),
        ],
        footer: (context) {
          final text = 'Page ${context.pageNumber} of ${context.pagesCount}';

          return Container(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(top: 1 * PdfPageFormat.cm),
            child: Text(
              text,
              style: TextStyle(color: PdfColors.black),
            ),
          );
        },
      ),
    );
    return saveDocument(name: 'ExpenseBook.pdf', pdf: pdf);
  }

  static Widget buildCustomHeader({buffer}) => Container(
        padding: EdgeInsets.only(bottom: 5, top: 5, left: 5),
        decoration: BoxDecoration(color: PdfColors.deepOrange),
        child: Row(
          children: [
            PdfLogo(
              color: PdfColors.white,
            ),
            SizedBox(width: 0.5 * PdfPageFormat.cm),
            Text(
              'Trip Expense Summary',
              style: TextStyle(fontSize: 20, color: PdfColors.white),
            ),
          ],
        ),
      );

  static Widget buildCustomHeadline({
    data,
  }) =>
      Header(
        child: Text(
          '${data['trip_name']}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: PdfColors.deepOrange,
          ),
        ),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 2, color: PdfColors.deepOrange300)),
        ),
      );

  // static Widget buildLink() => UrlLink(
  //   destination: 'https://flutter.dev',
  //   child: Text(
  //     'Go to flutter.dev',
  //     style: TextStyle(
  //       decoration: TextDecoration.underline,
  //       color: PdfColors.blue,
  //     ),
  //   ),
  // );

  static List<Widget> buildBulletPoints({data, totalex, perhead, currency, customFont, ttf}) => [
        Bullet(
          text: 'Place : ${data['trip_place_desc']}',
          style: TextStyle(color: PdfColors.black, fontSize: 18, font: ttf

              // fontWeight: FontWeight.w600,
              ),
        ),
        Bullet(
          text:
              'Date : ${parseDateRange(DateTime.fromMillisecondsSinceEpoch(data['${DatabaseHelper.colTripFromDate}']).toLocal(), DateTime.fromMillisecondsSinceEpoch(data['${DatabaseHelper.colTripToDate}']).toLocal())}',
          style: TextStyle(color: PdfColors.black, fontSize: 18, font: ttf
              // fontWeight: FontWeight.w600,
              ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            flex: 1,
            child: Bullet(
              text: 'Total Expense :  ',
              style: TextStyle(
                color: PdfColors.black,
                fontSize: 18,
                font: ttf,
                // fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
              flex: 3,
              child: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Text(
                    "  ${currency.toString()} $totalex",
                    style: TextStyle(
                      color: PdfColors.black,
                      fontSize: 13,
                      font: customFont,
                      // fontWeight: FontWeight.w600,
                    ),
                  )))
        ])
        // Bullet(
        //   text: 'Per Head Expense : ${currency.toString()} $perhead',
        //   style: TextStyle(
        //     color: PdfColors.black,
        //     fontSize: 14,
        //     font: customFont,
        //     // fontWeight: FontWeight.w600,
        //   ),
        // ),
      ];

  static Widget userTable({users, total, totalex, currency, customFont, ttf}) => Container(
        padding: EdgeInsets.only(bottom: 5 * PdfPageFormat.mm),
        // decoration: BoxDecoration(
        //   border: Border(bottom: BorderSide(width: 2, color: PdfColors.blue)),
        // ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Name',
                    style: TextStyle(fontSize: 16, color: PdfColors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Paid',
                    style: TextStyle(fontSize: 16, color: PdfColors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Per Head',
                    style: TextStyle(fontSize: 16, color: PdfColors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Balance',
                    style: TextStyle(fontSize: 16, color: PdfColors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ...List.generate(users.length, (index) {
              print(" Here Is Print $totalex and ${users[index]['data']['trip__user_part']} and $total");
              var expense = totalex * users[index]['data']['trip__user_part'] / total;
              var diffe = users[index]['expense'] - expense;
              print(" Differenace Is $diffe");
              return Container(
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 1, color: PdfColors.deepOrange200)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: pw.Text(
                          users[index]['data']['trip_user_name'].toString(),
                          style: TextStyle(
                            font: ttf,
                            color: PdfColors.black,
                            fontSize: 18,
                            // fontWeight: FontWeight.w600,
                          ),
                        ),
                        //  Text(
                        //   users[index]['data']['trip_user_name'].toString(),
                        //   style:
                        //       TextStyle(fontSize: 14, color: PdfColors.black),
                        // ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "${currency.toString()} ${num.parse(users[index]['expense'].toString()).toStringAsFixed(2)}",
                          style: TextStyle(color: PdfColors.black, fontSize: 14, font: customFont
                              // fontWeight: FontWeight.w600,
                              ),
                        ),
                        // Text(
                        //   "${currency.toString()} ${num.parse(users[index]['expense'].toString()).toStringAsFixed(2)}",
                        //   style: TextStyle(
                        //       fontSize: 14,
                        //       font: customFont,
                        //       color: PdfColors.black),
                        // ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "${currency.toString()} ${num.parse(expense.toString()).toStringAsFixed(2)}",
                          style: TextStyle(color: PdfColors.black, fontSize: 14, font: customFont
                              // fontWeight: FontWeight.w600,
                              ),
                        ),
                        // Text(
                        //   "${currency.toString()} ${num.parse(expense.toString()).toStringAsFixed(2)}",
                        //   style: TextStyle(
                        //       fontSize: 14,
                        //       font: customFont,
                        //       color: PdfColors.black),
                        // ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "(${diffe.toStringAsFixed(2)})",
                          style: TextStyle(color: PdfColors.black, fontSize: 14, font: customFont
                              // fontWeight: FontWeight.w600,
                              ),
                        ),
                        // Text(
                        //   "(${diffe.toStringAsFixed(2)})",
                        //   style: TextStyle(
                        //       fontSize: 14,
                        //       font: customFont,
                        //       color: PdfColors.black),
                        // ),
                      ),
                    ],
                  ));
            }),
          ],
        ),
      );

  static Widget categoryExpense({category, expense, currency, customFont, ttf}) => Container(
        padding: EdgeInsets.only(bottom: 5 * PdfPageFormat.mm),
        // decoration: BoxDecoration(
        //   border: Border(bottom: BorderSide(width: 2, color: PdfColors.blue)),
        // ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Category Name',
                    style: TextStyle(fontSize: 16, color: PdfColors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Paid',
                    style: TextStyle(fontSize: 16, color: PdfColors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ...List.generate(category.length, (index) {
              return Container(
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 1, color: PdfColors.deepOrange200)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: pw.Text(
                          category[index]['trip_cate_name'].toString(),
                          style: TextStyle(
                            font: ttf,
                            color: PdfColors.black,
                            fontSize: 18,
                            // fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: pw.Text(
                          "${currency.toString()} ${num.parse(expense[index]['total'].toString()).toStringAsFixed(2)}",
                          style: TextStyle(
                            font: customFont,
                            color: PdfColors.black,
                            fontSize: 14,
                            // fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ));
            }),
          ],
        ),
      );

  static Widget expenseItems(
    list, {
    currency,
    ttf,
    customFont,
  }) =>
      Container(
          child: Column(children: [
        ...List.generate(
            list.length,
            (index) => Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  padding: EdgeInsets.only(left: 15, top: 15),
                  decoration: BoxDecoration(
                      color: PdfColors.white,
                      boxShadow: [
                        // BoxShadow(
                        //   color: PdfColors.blue50,
                        //   blurRadius: 3.0,
                        // ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: PdfColors.deepOrange100)),
                  child: Column(
                    children: [
                      Row(children: [
                        Expanded(
                            child: Row(
                          children: [
                            pw.Text(
                              "${DateFormat("dd, MMM yyyy").format(DateTime.fromMillisecondsSinceEpoch(list[index]['${DatabaseHelper.colDateCreated}']))}, "
                                  .toString(),
                              style: TextStyle(
                                font: ttf,
                                color: PdfColors.black,
                                fontSize: 22,
                                // fontWeight: FontWeight.w600,
                              ),
                            ),
                            // Text(
                            //   "${DateFormat("dd, MMM yyyy").format(DateTime.fromMillisecondsSinceEpoch(list[index]['${DatabaseHelper.colDateCreated}']))}, ",
                            //   style: TextStyle(
                            //     color: PdfColors.black,
                            //     fontSize: 16,
                            //     // fontWeight: FontWeight600,
                            //   ),
                            // ),
                            Expanded(
                              child: pw.Text(
                                list[index]['${DatabaseHelper.colTripTime}'].toString(),
                                style: TextStyle(
                                  font: ttf,
                                  color: PdfColors.black,
                                  fontSize: 22,
                                  // fontWeight: FontWeight.w600,
                                ),
                              ),
                              //      Text(
                              //   list[index]['${DatabaseHelper.colTripTime}'],
                              //   style: TextStyle(
                              //     color: PdfColors.black,
                              //     fontSize: 16,
                              //     // fontWeight: FontWeight.w600,
                              //   ),
                              // )
                            ),
                          ],
                        )),
                        Expanded(
                            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          pw.Text(
                            "Expense By : ".toString(),
                            style: TextStyle(
                              font: ttf,
                              color: PdfColors.black,
                              fontSize: 22,
                              // fontWeight: FontWeight.w600,
                            ),
                          ),
                          // Text(
                          //   "Expense By : ",
                          //   style: TextStyle(
                          //     color: PdfColors.black,
                          //     fontSize: 16,
                          //     // fontWeight: FontWeight600,
                          //   ),
                          // ),
                          pw.Text(
                            list[index]['${DatabaseHelper.colTripUserName}'].toString(),
                            style: TextStyle(
                              font: ttf,
                              color: PdfColors.black,
                              fontSize: 22,
                              // fontWeight: FontWeight.w600,
                            ),
                          ),
                          // Text(
                          //   list[index]
                          //       ['${DatabaseHelper.colTripUserName}'],
                          //   style: TextStyle(
                          //     color: PdfColors.black,
                          //     fontSize: 16,
                          //     // fontWeight: FontWeight.w600,
                          //   ),
                          // ),
                          SizedBox(width: 10)
                        ])),
                      ]),
                      SizedBox(
                        height: 8,
                      ),
                      // SizedBox(
                      //   height: 3,
                      // ),
                      Row(
                        children: [
                          pw.Text(
                            "${list[index]['${DatabaseHelper.colTripCategoryName}']} - ".toString(),
                            style: TextStyle(
                              font: ttf,
                              color: PdfColors.black,
                              fontSize: 22,
                              // fontWeight: FontWeight.w600,
                            ),
                          ),
                          // Row(
                          //   children: [
                          // Text(
                          //   "${list[index]['${DatabaseHelper.colTripCategoryName}']} - ",
                          //   style: TextStyle(
                          //     color: PdfColors.black,
                          //     fontSize: 16,
                          //     // fontWeight: FontWeight600,
                          //   ),
                          // ),
                          Expanded(
                              child: pw.Text(
                            list[index]['${DatabaseHelper.colTripExpDesc}'].toString(),
                            style: TextStyle(
                              font: ttf,
                              color: PdfColors.black,
                              fontSize: 22,
                              // fontWeight: FontWeight.w600,
                            ),
                          )),

                          // Text(
                          //   "Expense By : ",
                          //   style: TextStyle(
                          //     color: PdfColors.black,
                          //     fontSize: 16,
                          //     // fontWeight: FontWeight600,
                          //   ),
                          // ),
                          // Expanded(
                          //     child: Text(
                          //   list[index]['${DatabaseHelper.colTripUserName}'],
                          //   style: TextStyle(
                          //     color: PdfColors.black,
                          //     fontSize: 16,
                          //     // fontWeight: FontWeight.w600,
                          //   ),
                          // )),
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              width: 120,
                              decoration: BoxDecoration(
                                color: PdfColors.deepOrange300,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              child: Text(
                                "${currency.toString()} ${list[index]['${DatabaseHelper.colTripExpAmount}']}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: PdfColors.white,
                                  font: customFont,
                                  fontSize: 18,
                                  // fontWeight: FontWeight.w600,
                                ),
                              )),
                        ],
                      ),
                      /*Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  pushNamedArg(route: rtEditTripExpensesScreen, args: item,thenFunc: (value){
                    setState(() {
                      isLoaded=false;
                    });
                    getData();
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.r),
                      bottomRight: Radius.circular(10.r),
                    ),
                  ),
                  child: Icon(Icons.edit,color: Colorshite,),
                ),
              )
            ],
          )*/
                    ],
                  ),
                ))
      ]));

  static Future<File> saveDocument({
    String? name,
    Document? pdf,
  }) async {
    final bytes = await pdf!.save();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');

    await file.writeAsBytes(bytes);
    OpenFile.open(file.path);
    return file;
  }
}
