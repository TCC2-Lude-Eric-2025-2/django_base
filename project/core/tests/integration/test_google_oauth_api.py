import pytest
from django.utils import timezone
from datetime import timedelta
from django.contrib.auth import get_user_model
from oauth2_provider.models import AccessToken, Application


@pytest.mark.django_db
class TestGoogleOAuthProfile:
    def _create_access_token(self, user):
        app, _ = Application.objects.get_or_create(
            name="Test App",
            client_type=Application.CLIENT_CONFIDENTIAL,
            authorization_grant_type=Application.GRANT_PASSWORD,
        )

        return AccessToken.objects.create(
            user=user,
            token="test-token-123",
            application=app,
            expires=timezone.now() + timedelta(days=1),
            scope="read write",
        )

    def test_profile_access_logged(self, client):
        User = get_user_model()

        user = User.objects.create_user(email="t@t.com", password="1234")

        token = self._create_access_token(user)

        client.force_login(user)

        response = client.get(
            "/profile/",
            HTTP_AUTHORIZATION=f"Bearer {token.token}",
        )

        assert response.status_code == 200
