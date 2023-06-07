defmodule Data.Context do
  import Ecto.Query, warn: false
  alias Data.Repo

  @moduledoc false

  @type changeset() :: %Ecto.Changeset{}

  @spec list(struct()) :: list(struct()) | []
  def list(model) do
    Repo.all(model)
  end

  def list(model, limit) do
    from(a in model,
      limit: ^limit
    )
    |> Repo.all()
  end

  def get_all!(model, ids) when is_list(ids) do
    Repo.all(
      from p in model,
        where: p.id in ^ids
    )
  end

  def count(model) do
    Repo.aggregate(model, :count)
  end

  def preload_selective(data, list) do
    Repo.preload(data, list)
  end

  def get!(model, id) do
    Repo.get!(model, id)
  end

  @spec get(struct(), binary()) :: struct() | nil
  def get(model, id) do
    Repo.get(model, id)
  end

  @spec create(module(), map()) :: {:ok, struct()} | {:error, changeset()}
  def create(model, attrs \\ %{}) do
    struct(model)
    |> model.changeset(attrs)
    |> Repo.insert()
  end

  @spec create_request(module(), map()) :: {:ok, struct()} | {:error, changeset()}
  def create_request(model, attrs \\ %{}) do
    struct(model)
    |> model.index_changeset(attrs)
    |> Repo.insert()
  end

  @spec update(module(), struct(), map()) :: {:ok, struct()} | {:error, changeset()}
  def update(model, data, attrs) do
    data
    |> model.changeset(attrs)
    |> Repo.update()
  end

  @spec update_nil_sub_type(module(), struct(), map()) :: {:ok, struct()} | {:error, changeset()}
  def update_nil_sub_type(model, data, attrs) do
    data
    |> model.nil_sub_type_changeset(attrs)
    |> Repo.update()
  end

  @spec update_reviewer_password(module(), struct(), map()) ::
          {:ok, struct()} | {:error, changeset()}
  def update_reviewer_password(model, data, attrs) do
    data
    |> model.update_reviewer_pass_changeset(attrs)
    |> Repo.update()
  end

  def update_request_source_description(model, data, attrs) do
    data
    |> model.source_desc_changeset(attrs)
    |> Repo.update()
  end

  @spec update_archive_status(module(), struct(), map()) ::
          {:ok, struct()} | {:error, changeset()}
  def update_archive_status(model, data, attrs) do
    data
    |> model.archive_changeset(attrs)
    |> Repo.update()
  end

  @spec update_justification(module(), struct(), map()) :: {:ok, struct()} | {:error, changeset()}
  def update_justification(model, data, attrs) do
    data
    |> model.justification_changeset(attrs)
    |> Repo.update()
  end

  def update_stepper_status(model, data, attrs) do
    data
    |> model.stepper_status_changeset(attrs)
    |> Repo.update()
  end

  def create_range(model, attrs \\ %{}) do
    struct(model)
    |> model.changeset_range(attrs)
    |> Repo.insert()
  end

  def create_spec_date(model, attrs \\ %{}) do
    struct(model)
    |> model.changeset_date_list(attrs)
    |> Repo.insert()
  end

  def create_collection_type(model, attrs \\ %{}) do
    struct(model)
    |> model.changeset_for_collection(attrs)
    |> Repo.insert()
  end

  def update_collection_type(model, data, attrs) do
    data
    |> model.changeset_for_collection(attrs)
    |> Repo.update()
  end

  def update_multiple(model, ids, attrs) do
    from(p in model, where: p.request_id in ^ids, update: [set: ^attrs])
    |> Repo.update_all([])
  end

  def delete_all(modal, ids) when is_list(ids) do
    from(f in modal, where: f.id in ^ids)
    |> Repo.delete_all()
  end

  @spec delete(list(struct())) :: :ok
  def delete(data) when is_list(data) do
    Enum.each(data, &Repo.delete(&1))
  end

  @spec delete(struct()) :: {:ok, struct()} | {:error, changeset()}
  def delete(data) do
    if data != nil do
      Repo.delete(data)
    else
      {:error, :no_record_found}
    end
  end

  @spec change(module(), struct(), map()) :: changeset()
  def change(model, data, attrs \\ %{}) do
    model.changeset(data, attrs)
  end

  def changeset_range(model, data, attrs \\ %{}) do
    model.changeset_range(data, attrs)
  end

  def changeset_date_list(model, data, attrs \\ %{}) do
    model.changeset_date_list(data, attrs)
  end

  @spec justification_changeset(module(), struct(), map()) :: changeset()
  def justification_changeset(model, data, attrs \\ %{}) do
    model.justification_changeset(data, attrs)
  end

  #  @spec change(struct(), struct(), map()) :: changeset()
  def index_changeset(model, data, attrs \\ %{}) do
    model.index_changeset(data, attrs)
  end

  def change_source_desc(model, data, attrs \\ %{}) do
    model.source_desc_changeset(data, attrs)
  end

  @spec update_p_in_org_role(module(), struct(), map()) :: {:ok, struct()} | {:error, changeset()}
  def update_p_in_org_role(model, data, attrs) do
    data
    |> model.end_changeset(attrs)
    |> Repo.update()
  end
end
