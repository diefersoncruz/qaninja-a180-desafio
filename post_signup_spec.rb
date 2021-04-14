require_relative "routes/signup"
require_relative "libs/mongo"

describe "POST /signup" do
  context "Novo usuario" do
    before(:all) do
      payload = { name: "Gesieli", email: "ge@gmail.com", password: "1234" }
      MongoDB.new.remove_user(payload[:email])
      @result = Signup.new.create(payload)
    end

    it "valida status code" do
      expect(@result.code).to eql 200
    end

    it "valida id do usuário" do
      expect(@result.parsed_response["_id"].length).to eql 24
    end
  end

  context "Usuario ja existe" do
    before(:all) do
      payload = { name: "João Roberto", email: "jr@gmail.com", password: "1234" }
      MongoDB.new.remove_user(payload[:email])

      Signup.new.create(payload)
      @result = Signup.new.create(payload)
    end

    it "Deve retornar 409" do
      expect(@result.code).to eql 409
    end

    it "deve retornar mensagem de erro" do
      expect(@result.parsed_response["error"]).to eql "Email already exists :("
    end
  end
  # Nome obrigatorio
  # email obrigatorio
  # password obrigatorio

  examples = [
    {
      title: "Nome obrigatorio",
      payload: { name: "", email: "pedro@bol.com", password: "1234" },
      code: 412,
      error: "required name",
    },
    {
      title: "Sem o campo nome",
      payload: { email: "pedro@bol.com", password: "1234" },
      code: 412,
      error: "required name",
    },
    {
      title: "Email obrigatorio",
      payload: { name: "Pedro", email: "", password: "1234" },
      code: 412,
      error: "required email",
    },
    {
      title: "Sem o campo email",
      payload: { name: "Pedro", password: "1234" },
      code: 412,
      error: "required email",
    },
    {
      title: "Password obrigatorio",
      payload: { name: "Pedro", email: "pedro@bol.com.br", password: "" },
      code: 412,
      error: "required password",
    },
    {
      title: "Sem o campo password",
      payload: { name: "Pedro", email: "pedro@bol.com.br" },
      code: 412,
      error: "required password",
    },
  ]

  examples.each do |e|
    context "#{e[:title]}" do
      before(:all) do
        @result = Signup.new.create(e[:payload])
      end

      it "valida status code #{e[:code]}" do
        expect(@result.code).to eql e[:code]
      end

      it "valida id do usuário" do
        expect(@result.parsed_response["error"]).to eql e[:error]
      end
    end
  end
end
