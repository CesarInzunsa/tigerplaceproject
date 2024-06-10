import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:image_picker/image_picker.dart';

import '../../controller/user_controller.dart';
import '../../model/service_model.dart';

import 'package:day_picker/day_picker.dart';

class EditService extends StatefulWidget {
  final ServiceModel service;

  const EditService({super.key, required this.service});

  @override
  State<EditService> createState() => _EditServiceState();
}

class _EditServiceState extends State<EditService> {
  // Key for the form
  final _formKey = GlobalKey<FormState>();

  // Controllers for the form fields
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Comida');
  final _scheduleController = TextEditingController();
  final List<String> _availableDays = [];
  final List<File?> _imgFiles = [];
  final _priceController = TextEditingController();
  bool _stateController = true;

  final _horaInicioController = TextEditingController();
  final _horaFinController = TextEditingController();

  final List<String> _categoryItems = [
    'Comida',
    'Accesorios',
    'Calzado',
    'Ropa',
    'Tecnología',
  ];

  final List<DayInWeek> _days = [
    DayInWeek(
      "Sun",
      dayKey: 'Domingo',
    ),
    DayInWeek(
      "Mon",
      dayKey: 'Lunes',
    ),
    DayInWeek(
      "Tue",
      dayKey: 'Martes',
    ),
    DayInWeek(
      "Wed",
      dayKey: 'Miercoles',
    ),
    DayInWeek(
      "Thu",
      dayKey: 'Jueves',
    ),
    DayInWeek(
      "Fri",
      dayKey: 'Viernes',
    ),
    DayInWeek(
      "Sat",
      dayKey: 'Sabado',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.service.name;
    _descriptionController.text = widget.service.description;
    _priceController.text = widget.service.price.toString();
    _stateController = widget.service.state;
    _horaInicioController.text = widget.service.schedule.split(' - ')[0];
    _horaFinController.text = widget.service.schedule.split(' - ')[1];

    for(var day in widget.service.availableDays){
      for(var dayOfWeek in _days){
        if(day == dayOfWeek.dayKey){
          dayOfWeek.isSelected = true;
        }
      }
    }

    setState(() {
      _days;
    });

    _availableDays.addAll(widget.service.availableDays);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Servicio'),
      ),
      body: _displayForm(),
    );
  }

  Widget _displayForm() {
    double screenWidth = MediaQuery.of(context).size.width;
    EdgeInsets paddingValue = screenWidth > 600 ? const EdgeInsets.symmetric(horizontal: 200) : EdgeInsets.zero;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: paddingValue,
        child: Column(
          children: [
            _drawFormField(_nameController, 'Nombre'),
            _drawFormField(_descriptionController, 'Descripción'),
            _displayComboBox(),
            //horario
            Padding(
              padding: const EdgeInsets.only(top: 11, bottom: 11),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: _displayCheckboxField(),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: _displayPriceField(),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 11, bottom: 11),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: _displayInitialScheduleField(),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: _displayEndScheduleField(),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 11, left: 15, right: 15),
              child: _drawAvailableDaysField(),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 11, left: 15, right: 15),
              child: _displayImagesPickerField(),
            ),
            _displayImagesGallery(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _displaySubmitButton(),
                _displayCancelButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawAvailableDaysField() {
    return SelectWeekDays(
      days: _days,
      onSelect: (values) {
        // lista temporal para guardar los dias seleccionados
        List<String> availableDaysTemp = [];

        // Guardar los dias seleccionados
        for (var day in values) {
          availableDaysTemp.add(day.toString());
        }

        // Limpiar la lista de dias disponibles
        _availableDays.clear();

        // Ordenar los dias seleccionados
        _availableDays.addAll(_sortDaysOfWeek(availableDaysTemp));

        // Mostrar los dias seleccionados en la consola
        log(_availableDays.toString());
      },
      backgroundColor: Colors.transparent,
      unSelectedDayTextColor: Colors.black,
      selectedDayTextColor: Colors.black,
      daysFillColor: Colors.purple[50],
      border: false,
    );
  }

  List<String> _sortDaysOfWeek(List<String> days) {
    // Lista de referencia con los días de la semana en el orden correcto
    List<String> reference = [
      'Lunes',
      'Martes',
      'Miercoles',
      'Jueves',
      'Viernes',
      'Sabado',
      'Domingo'
    ];

    // Ordenar la lista de días proporcionada
    days.sort((a, b) => reference.indexOf(a).compareTo(reference.indexOf(b)));

    return days;
  }

  Widget _displayComboBox() {
    return DropdownButtonFormField(
      padding: const EdgeInsets.only(left: 22, right: 22),
      value: _categoryController.text,
      items: _categoryItems.map((e) {
        return DropdownMenuItem(
          value: e,
          child: Text(e),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _categoryController.text = value.toString();
        });
      },
    );
  }

  Widget _displayImagesPickerField() {
    return TextFormField(
      onTap: () async {
        File? imgFile;

        final ImagePicker picker = ImagePicker();

        final List<XFile?> imgs = await picker.pickMultiImage();

        if (imgs.isEmpty) {
          return;
        }

        for (var img in imgs) {
          imgFile = File(img!.path); // convert it to a Dart:io file
          _imgFiles.add(imgFile);
          log(img.path);
        }

        setState(() {
          _imgFiles;
        });
      },
      readOnly: true,
      decoration: const InputDecoration(
        hintText: 'Imagenes',
        filled: true,
        prefixIcon: Icon(Icons.image_outlined),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(),
      ),
    );
  }

  Widget _displayImagesGallery() {
    if (_imgFiles.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 11, left: 22, right: 22),
        child: SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _imgFiles.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(_imgFiles[index]!),
              );
            },
          ),
        ),
      );
    } else {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text('No se han seleccionado imágenes')],
      );
    }
  }

  Widget _displayCheckboxField() {
    return CheckboxListTile(
      title: const Text('Estado'),
      value: _stateController,
      onChanged: (bool? value) {
        setState(() {
          _stateController = value!;
        });
      },
    );
  }

  Widget _displayPriceField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11, left: 22, right: 22),
      child: TextFormField(
        controller: _priceController,
        decoration: const InputDecoration(
          labelText: 'Precio',
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        validator: (value) {
          if (value!.isEmpty) {
            return 'Por favor, ingrese un valor';
          }
          return null;
        },
      ),
    );
  }

  Widget _displayInitialScheduleField() {
    return TextField(
      controller: _horaInicioController,
      readOnly: true,
      decoration: const InputDecoration(
        hintText: 'Hora de inicio',
        filled: true,
        prefixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(),
      ),
      onTap: () {
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((value) {
          if (value != null) {
            _horaInicioController.text = value.format(context);
          }
        });
      },
    );
  }

  Widget _displayEndScheduleField() {
    return TextField(
      controller: _horaFinController,
      readOnly: true,
      decoration: const InputDecoration(
        hintText: 'Hora de fin',
        filled: true,
        prefixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(),
      ),
      onTap: () {
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((value) {
          if (value != null) {
            _horaFinController.text = value.format(context);
          }
        });
      },
    );
  }

  Widget _displaySubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 33),
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            // Validar que se hayan seleccionado los horarios de inicio y fin
            if (_horaInicioController.text.isEmpty ||
                _horaFinController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Por favor, seleccione un horario de inicio y fin'),
                ),
              );
              return;
            }

            // Extraer la hora de inicio y fin
            TimeOfDay horaInicio = TimeOfDay(
              hour: int.parse(_horaInicioController.text.split(':')[0]),
              minute: int.parse(_horaInicioController.text.split(':')[1]),
            );

            TimeOfDay horaFin = TimeOfDay(
              hour: int.parse(_horaFinController.text.split(':')[0]),
              minute: int.parse(_horaFinController.text.split(':')[1]),
            );

            // Convertir a Double
            double horaInicioDouble = horaInicio.hour.toDouble() +
                (horaInicio.minute.toDouble() / 60);
            double horaFinDouble =
                horaFin.hour.toDouble() + (horaFin.minute.toDouble() / 60);

            // Validar que la hora de inicio sea menor a la hora de fin
            if (horaInicioDouble >= horaFinDouble) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('La hora de inicio debe ser menor a la hora de fin'),
                ),
              );
              return;
            }

            // Declarar el schedule
            _scheduleController.text =
                '${_horaInicioController.text} - ${_horaFinController.text}';

            // Save the product
            ServiceModel service = ServiceModel(
              id: widget.service.id,
              name: _nameController.text,
              description: _descriptionController.text,
              category: _categoryController.text,
              schedule: _scheduleController.text,
              availableDays: _availableDays,
              images: widget.service.images,
              price: int.parse(_priceController.text),
              ratingAvg: 0.0,
              ratingCount: 0,
              state: _stateController,
              calificaciones: [],
            );

            // mostrar un dialogo de carga mientras se guarda el producto
            showDialog(
              context: context,
              builder: (context) => FutureProgressDialog(
                UserController().updateOneService(
                    UserController().getMyProfileId(), service, _imgFiles),
                message: const Text('Publicando servicio...'),
              ),
            ).then((value) {
              if (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Servicio guardado'),
                  ),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error al guardar el servicio'),
                  ),
                );
              }
            });
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          minimumSize: const Size(88, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ),
        child: const Text('Guardar'),
      ),
    );
  }

  Widget _displayCancelButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 33),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          minimumSize: const Size(88, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ),
        child: const Text('Cancelar'),
      ),
    );
  }

  Widget _drawFormField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11, left: 22, right: 22),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Por favor, ingrese un valor';
          }
          return null;
        },
      ),
    );
  }
}
