defmodule Discuss.AuthController do
  use Discuss.Web, :controller
  plug Ueberauth

  alias Discuss.User

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
    user_params = %{ token: auth.credentials.token, email: auth.info.email, provider: "github"}

    signin(conn, user_params)
  end

  def signout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "Logged out")
    |> redirect(to: topic_path(conn, :index))
  end

  defp signin(conn, user_params) do
    case insert_or_update_user(user_params) do

      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> put_session(:user_id, user.id)
        |> redirect(to: topic_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Oeps")
        |> redirect(to: topic_path(conn, :index))
    end
  end

  defp insert_or_update_user(user_params) do
      case Repo.get_by(User, email: user_params.email) do
        nil  -> %User{}
        user -> user
      end
      |> User.changeset(user_params)
      |> Repo.insert_or_update
  end
end
