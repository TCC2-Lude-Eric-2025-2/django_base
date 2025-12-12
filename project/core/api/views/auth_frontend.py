from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from django.views.decorators.http import require_GET


@require_GET
def login_page(request):
    return render(request, "login.html")


@require_GET
@login_required
def profile_page(request):
    user = request.user
    return render(request, "profile.html", {"user": user})
