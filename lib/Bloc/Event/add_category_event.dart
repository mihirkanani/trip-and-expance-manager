import 'package:flutter/material.dart';

abstract class AddCategoryEvent {
  const AddCategoryEvent();
}

class AddCategoryLoadEvent extends AddCategoryEvent {
  AddCategoryLoadEvent();
}

class GetCategoriesEvent extends AddCategoryEvent {
  GetCategoriesEvent();
}

class ChangeDateAndTimeEvent extends AddCategoryEvent {
  BuildContext context;

  ChangeDateAndTimeEvent(this.context);
}

class InsertIncomeEvent extends AddCategoryEvent {
  BuildContext context;

  InsertIncomeEvent(this.context);
}

class InsertExpanseEvent extends AddCategoryEvent {
  BuildContext context;

  InsertExpanseEvent(this.context);
}

class InsertCategoriesEvent extends AddCategoryEvent {
  BuildContext context;
  var catName;
  var selectCatIcon;

  InsertCategoriesEvent(this.context, this.catName, this.selectCatIcon);
}
class ChangeTabEvent extends AddCategoryEvent {
  BuildContext context;

  ChangeTabEvent(this.context);
}