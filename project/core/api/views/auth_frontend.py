from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from django.shortcuts import render


def login_page(request):
    return render(request, "login.html")


@login_required
def profile_page(request):
    user = request.user
    return render(request, "profile.html", {"user": user})
