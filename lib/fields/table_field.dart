import 'package:flutter/material.dart';
import 'package:folly_fields/crud/abstract_consumer.dart';
import 'package:folly_fields/crud/abstract_model.dart';
import 'package:folly_fields/crud/abstract_ui_builder.dart';
import 'package:folly_fields/widgets/add_button.dart';
import 'package:folly_fields/widgets/delete_button.dart';
import 'package:folly_fields/widgets/empty_button.dart';
import 'package:folly_fields/widgets/field_group.dart';
import 'package:folly_fields/widgets/folly_divider.dart';
import 'package:folly_fields/widgets/header_cell.dart';

///
///
///
// TODO(edufolly): Test layout with DataTable.
// TODO(edufolly): Customize messages.
// TODO(edufolly): Create controller??
class TableField<T extends AbstractModel<Object>> extends FormField<List<T>> {
  ///
  ///
  ///
  TableField({
    required List<T> initialValue,
    required AbstractUIBuilder<T> uiBuilder,
    required AbstractConsumer<T> consumer,
    required List<String> columns,
    required List<Widget> Function(
      BuildContext context,
      T row,
      int index,
      List<T> data,
      bool enabled,
    )
        buildRow,
    List<int> columnsFlex = const <int>[],
    Future<bool> Function(BuildContext context, List<T> data)? beforeAdd,
    Future<bool> Function(BuildContext context, T row, int index, List<T> data)?
        removeRow,
    FormFieldSetter<List<T>>? onSaved,
    FormFieldValidator<List<T>>? validator,
    bool enabled = true,
    bool showAddButton = true,
    AutovalidateMode autoValidateMode = AutovalidateMode.disabled,
    Widget Function(BuildContext context, List<T> data)? buildFooter,
    InputDecoration? decoration,
    EdgeInsets padding = const EdgeInsets.all(8),
    Key? key,
  })  : assert(columnsFlex.length == columns.length,
            'initialValue or controller must be null.'),
        super(
          key: key,
          initialValue: initialValue,
          enabled: enabled,
          onSaved: enabled && onSaved != null
              ? (List<T>? value) => onSaved(value)
              : null,
          validator: enabled && validator != null
              ? (List<T>? value) => validator(value)
              : null,
          autovalidateMode: autoValidateMode,
          builder: (FormFieldState<List<T>> field) {
            TextStyle? columnHeaderTheme =
                Theme.of(field.context).textTheme.subtitle2;

            Color disabledColor = Theme.of(field.context).disabledColor;

            if (columnHeaderTheme != null && !enabled) {
              columnHeaderTheme =
                  columnHeaderTheme.copyWith(color: disabledColor);
            }

            InputDecoration effectiveDecoration = (decoration ??
                    InputDecoration(
                      labelText: uiBuilder.getSuperPlural(),
                      border: const OutlineInputBorder(),
                      counterText: '',
                      enabled: enabled,
                      errorText: field.errorText,
                    ))
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);

            return FieldGroup(
              padding: padding,
              decoration: effectiveDecoration,
              children: <Widget>[
                if (field.value!.isEmpty)

                  /// Empty table
                  SizedBox(
                    height: 75,
                    child: Center(
                      child: Text(
                        'Sem ${uiBuilder.getSuperPlural()} até o momento.',
                      ),
                    ),
                  )
                else

                  /// Table
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: <Widget>[
                        /// Header
                        Row(
                          children: <Widget>[
                            /// Columns Names
                            ...columns
                                .asMap()
                                .entries
                                .map<Widget>(
                                  (MapEntry<int, String> entry) => HeaderCell(
                                    flex: columnsFlex[entry.key],
                                    child: Text(
                                      entry.value,
                                      style: columnHeaderTheme,
                                    ),
                                  ),
                                )
                                .toList(),

                            /// Empty column to delete button
                            if (removeRow != null) const EmptyButton(),
                          ],
                        ),

                        /// Table data
                        ...field.value!.asMap().entries.map<Widget>(
                              (MapEntry<int, T> entry) => Column(
                                children: <Widget>[
                                  /// Divider
                                  FollyDivider(
                                    color: enabled ? null : disabledColor,
                                  ),

                                  /// Row
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      /// Cells
                                      ...buildRow(
                                        field.context,
                                        entry.value,
                                        entry.key,
                                        field.value!,
                                        enabled,
                                      )
                                          .asMap()
                                          .entries
                                          .map<Widget>(
                                            (MapEntry<int, Widget> entry) =>
                                                Flexible(
                                              flex: columnsFlex[entry.key],
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: entry.value,
                                              ),
                                            ),
                                          )
                                          .toList(),

                                      /// Delete button
                                      if (removeRow != null)
                                        DeleteButton(
                                          enabled: enabled,
                                          onPressed: () async {
                                            bool go = await removeRow(
                                              field.context,
                                              entry.value,
                                              entry.key,
                                              field.value!,
                                            );
                                            if (!go) {
                                              return;
                                            }
                                            field.value!.removeAt(entry.key);
                                            field.didChange(field.value);
                                          },
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                        /// Footer
                        if (buildFooter != null)
                          buildFooter(field.context, field.value!),
                      ],
                    ),
                  ),

                /// Add button
                if (showAddButton)
                  AddButton(
                    enabled: enabled,
                    label:
                        'Adicionar ${uiBuilder.getSuperSingle()}'.toUpperCase(),
                    onPressed: () async {
                      if (beforeAdd != null) {
                        bool go = await beforeAdd(field.context, field.value!);
                        if (!go) {
                          return;
                        }
                      }

                      field.value!.add(consumer.fromJson(<String, dynamic>{}));
                      field.didChange(field.value);
                    },
                  ),
              ],
            );
          },
        );
}
