import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/products/domain/domain.dart';
import 'package:teslo_shop/features/products/presentation/providers/providers.dart';
import 'package:teslo_shop/features/shared/shared.dart';

class ProductScreen extends ConsumerWidget {
  final String productId;
  const ProductScreen({super.key, required this.productId});

  void showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Producto actualizado')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productProvider(productId));
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Editar Producto'),
          actions: [
            IconButton(
                onPressed: () async {
                  final String? photoPath =
                      await CameraGalleryServiceImpl().selectPhoto();
                  if (photoPath == null) return;
                  ref
                      .read(productFormProvider(productState.product!).notifier)
                      .updateProductImages(photoPath);
                },
                icon: const Icon(Icons.photo_library_outlined)),
            IconButton(
                onPressed: () async {
                  final String? photoPath =
                      await CameraGalleryServiceImpl().takePhoto();
                  if (photoPath == null) return;

                  ref
                      .read(productFormProvider(productState.product!).notifier)
                      .updateProductImages(photoPath);
                },
                icon: const Icon(Icons.camera_alt_outlined))
          ],
        ),
        body: productState.isLoading
            ? const FullScreenLoader()
            : _ProductView(product: productState.product!),
        //  Center(
        //   child: Text(productState.product?.title ?? 'Cargando'),
        // ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (productState.product == null) return;
            FocusScope.of(context).unfocus();
            ref
                .read(productFormProvider(productState.product!).notifier)
                .onFormSubmit()
                .then((value) {
              if (!value) return;
              showSnackBar(context);
            });
          },
          child: const Icon(Icons.save),
        ),
      ),
    );
  }
}

class _ProductView extends ConsumerWidget {
  final Product product;

  const _ProductView({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = Theme.of(context).textTheme;

    final productForm = ref.watch(productFormProvider(product));

    return ListView(
      children: [
        SizedBox(
          height: 250,
          width: 600,
          child: _ImageGallery(images: productForm.images),
        ),
        const SizedBox(height: 10),
        Center(
            child: Text(productForm.title.value,
                textAlign: TextAlign.center, style: textStyles.titleSmall)),
        const SizedBox(height: 10),
        _ProductInformation(product: product),
      ],
    );
  }
}

class _ProductInformation extends ConsumerWidget {
  final Product product;
  const _ProductInformation({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productForm = ref.watch(productFormProvider(product));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Generales'),
          const SizedBox(height: 15),
          CustomProductField(
            isTopField: true,
            label: 'Nombre',
            initialValue: productForm.title.value,
            onChanged: (value) => ref
                .read(productFormProvider(product).notifier)
                .onTitleChanged(value),
            errorMessage: productForm.title.errorMessage,
          ),
          CustomProductField(
            label: 'Slug',
            initialValue: productForm.slug.value,
            onChanged: (value) => ref
                .read(productFormProvider(product).notifier)
                .onSlugChanged(value),
            errorMessage: productForm.slug.errorMessage,
          ),
          CustomProductField(
            isBottomField: true,
            label: 'Precio',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            initialValue: productForm.price.value.toString(),
            onChanged: (value) => ref
                .read(productFormProvider(product).notifier)
                .onPriceChanged(double.tryParse(value) ?? -1),
            errorMessage: productForm.price.errorMessage,
          ),
          const SizedBox(height: 15),
          const Text('Extras'),
          _SizeSelector(
              selectedSizes: productForm.sizes,
              onSizeChanged: ref
                  .read(productFormProvider(product).notifier)
                  .onSizeChanged),
          const SizedBox(height: 5),
          _GenderSelector(
            selectedGender: productForm.gender,
            onGenderChanged:
                ref.read(productFormProvider(product).notifier).onGenderChanged,
          ),
          const SizedBox(height: 15),
          CustomProductField(
            isTopField: true,
            label: 'Existencias',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            initialValue: productForm.inStock.value.toString(),
            onChanged: (value) => ref
                .read(productFormProvider(product).notifier)
                .onStockChanged(int.tryParse(value) ?? -1),
            errorMessage: productForm.inStock.errorMessage,
          ),
          CustomProductField(
            maxLines: 6,
            label: 'Descripción',
            keyboardType: TextInputType.multiline,
            initialValue: productForm.description,
            onChanged: (value) => ref
                .read(productFormProvider(product).notifier)
                .onDescriptionChanged(value),
          ),
          CustomProductField(
            isBottomField: true,
            maxLines: 2,
            label: 'Tags (Separados por coma)',
            keyboardType: TextInputType.multiline,
            initialValue: productForm.tags,
            onChanged: (value) => ref
                .read(productFormProvider(product).notifier)
                .onTagsChanged(value),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _SizeSelector extends StatelessWidget {
  final List<String> selectedSizes;
  final List<String> sizes = const ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL'];
  final Function(List<String> selectedSizes) onSizeChanged;
  const _SizeSelector(
      {required this.selectedSizes, required this.onSizeChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
      emptySelectionAllowed: true,
      showSelectedIcon: false,
      segments: sizes.map((size) {
        return ButtonSegment(
            value: size,
            label: Text(size, style: const TextStyle(fontSize: 10)));
      }).toList(),
      selected: Set.from(selectedSizes),
      onSelectionChanged: (newSelection) {
        FocusScope.of(context).unfocus();
        onSizeChanged(List.from(newSelection));
      },
      multiSelectionEnabled: true,
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final String selectedGender;
  final List<String> genders = const ['men', 'women', 'kid'];
  final List<IconData> genderIcons = const [
    Icons.man,
    Icons.woman,
    Icons.boy,
  ];
  final Function(String selectedGender) onGenderChanged;
  const _GenderSelector(
      {required this.selectedGender, required this.onGenderChanged});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SegmentedButton(
        emptySelectionAllowed: false,
        multiSelectionEnabled: false,
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
        segments: genders.map((size) {
          return ButtonSegment(
              icon: Icon(genderIcons[genders.indexOf(size)]),
              value: size,
              label: Text(size, style: const TextStyle(fontSize: 12)));
        }).toList(),
        selected: {selectedGender},
        onSelectionChanged: (newSelection) {
          FocusScope.of(context).unfocus();
          onGenderChanged(newSelection.first);
        },
      ),
    );
  }
}

class _ImageGallery extends StatelessWidget {
  final List<String> images;
  const _ImageGallery({required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: Image.asset('assets/images/no-image.jpg', fit: BoxFit.cover));
    }

    return PageView(
      scrollDirection: Axis.horizontal,
      controller: PageController(viewportFraction: 0.7),
      children: images.map((e) {
        late ImageProvider imageProvider;
        if (e.startsWith('http')) {
          imageProvider = NetworkImage(e);
        } else {
          imageProvider = FileImage(File(e));
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: FadeInImage(
                fit: BoxFit.cover,
                placeholder:
                    const AssetImage('assets/loaders/bottle-loader.gif'),
                image: imageProvider,
              )),
        );
      }).toList(),
    );
  }
}
