from django.test import TestCase
from django.contrib.auth import get_user_model


class ProfilePageTest(TestCase):
    def test_profile_requires_auth(self):
        response = self.client.get("/profile/")
        self.assertEqual(response.status_code, 302)
        self.assertIn("/login/", response.url)


class ProfilePageLoggedTest(TestCase):
    def test_profile_access_logged(self):
        User = get_user_model()
        user = User.objects.create_user(email="test@example.com", password="1234")

        self.client.login(email="test@example.com", password="1234")
        response = self.client.get("/profile/")
        self.assertEqual(response.status_code, 200)
