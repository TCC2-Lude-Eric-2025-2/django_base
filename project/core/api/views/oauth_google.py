from django.views.decorators.http import require_GET


@require_GET
def google_login(request):
    raise NotImplementedError("Implementar na Etapa 2")


@require_GET
def google_callback(request):
    raise NotImplementedError("Implementar na Etapa 2")
