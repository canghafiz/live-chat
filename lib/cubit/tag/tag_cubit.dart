import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'tag_state.dart';

class TagCubitHandle {
  static TagCubit read(BuildContext context) {
    return context.read<TagCubit>();
  }

  static TagCubit watch(BuildContext context) {
    return context.watch<TagCubit>();
  }
}

enum TagType { personal, group }

class TagCubit extends Cubit<TagState> {
  TagCubit() : super(TagState(TagType.personal));

  void setTag(TagType value) {
    emit(TagState(value));
  }

  void clear() {
    emit(TagState(TagType.personal));
  }
}
