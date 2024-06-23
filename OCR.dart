void selectFile() async {
    if (html.window.navigator.userAgent.toLowerCase().contains('chrome') ||
        html.window.navigator.userAgent.toLowerCase().contains('safari')) {
      html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = '.pdf,.jpg,.jpeg,.png';
      uploadInput.click();

      uploadInput.onChange.listen((e) async {
        final files = uploadInput.files;
        if (files!.isNotEmpty) {
          final reader = html.FileReader();
          reader.readAsArrayBuffer(files[0]);
          reader.onLoadEnd.listen((e) async {
            var result = reader.result;
            if (result is Uint8List) {
              fileBytes.value = result;
              fileName.value = files[0].name!;
              performOCRforDOC();
            } else {
              print('Erro ao ler o arquivo como Uint8List.');
            }
          });
        } else {
          print('Nenhum arquivo selecionado.');
        }
      });
    } else {
      print('Seletor de arquivos não suportado neste navegador.');
    }
  }

  void performOCRforDOC() async {
    var url = Uri.parse('https://api.edenai.run/v2/ocr/ocr_async');
    var headers = {
      "Authorization":
          "Bearer ------- API KEY HERE -------"
    };

    var request = http.MultipartRequest('POST', url)
      ..headers.addAll(headers)
      ..fields['providers'] = 'microsoft'
      ..files.add(http.MultipartFile.fromBytes(
          'file',
          fileBytes.value!,
          filename: fileName.value,
          contentType: parser.MediaType('application', 'pdf')));

    try {
      var response = await request.send();
      var responseBody = await response.stream.toBytes();
      
      if (response.statusCode == 200) {
        var result = jsonDecode(utf8.decode(responseBody));
        print('Resposta recebida: $result');
        
        String? jobId = result["public_id"];
        if (jobId != null && jobId.isNotEmpty) {
          print('Solicitação OCR enviada com sucesso. Job ID: $jobId');
          await Future.delayed(Duration(seconds: 4));
          checkOCRResultDOC(jobId);
        } else {
          print('Erro ao obter job_id.');
        }
      } else {
        print('Erro na resposta: ${String.fromCharCodes(responseBody)}');
      }
    } catch (e) {
      print("Erro durante a execução: $e");
    }
  }

  void checkOCRResultDOC(String jobId) async {
    var url = Uri.parse('https://api.edenai.run/v2/ocr/ocr_async/$jobId');
    var headers = {
      "Authorization":
          "Bearer ---------------------- API KEY HERE ----------------------"
    };

    try {
      var response = await http.get(url, headers: headers);
      var responseBody = response.bodyBytes;
      
      if (response.statusCode == 200) {
        print('Resposta do OCR: ${String.fromCharCodes(responseBody)}');
        var result = jsonDecode(utf8.decode(responseBody));
        var microsoftResult = result["results"]["microsoft"];
        if (microsoftResult != null && microsoftResult["final_status"] == "succeeded") {
          if (microsoftResult["pages"] != null && microsoftResult["pages"].isNotEmpty) {
            ocrText.value = microsoftResult["pages"].map((page) {
              return page["lines"].map((line) => line["text"]).join("\n");
            }).join("\n");

            // Remove números no início das linhas de parágrafos
            ocrText.value = removeNumbersBeforeLines(ocrText.value);

            print('Texto extraído via OCR: ${ocrText.value}');
          } else {
            print('Nenhum texto foi encontrado via OCR.');
          }
        } else if (microsoftResult != null && microsoftResult["final_status"] == "processing") {
          print('O OCR ainda está em processamento. Verificando novamente em 10 segundos...');
          await Future.delayed(Duration(seconds: 10));
          checkOCRResultDOC(jobId);
        } else {
          print('Erro: resultado da microsoft é nulo ou o status final não é "succeeded".');
        }
      } else {
        print('Falha ao obter o resultado do OCR. Código de Status: ${response.statusCode}');
        print('Erro na resposta: ${String.fromCharCodes(responseBody)}');
      }
    } catch (e) {
      print("Erro ao obter o resultado do OCR: $e");
    }
  }

  String removeNumbersBeforeLines(String text) {
    RegExp regex = RegExp(r'^\d{1,2}\s*');

    return text.replaceAll(regex, '');
  }
}
