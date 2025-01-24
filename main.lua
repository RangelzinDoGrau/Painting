local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Para criar a interface (GUI) e o botão
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportGui"
ScreenGui.ResetOnSpawn = false  -- para não sumir ao respawnar

local TeleportButton = Instance.new("TextButton")
TeleportButton.Name = "TeleportButton"
TeleportButton.Size = UDim2.new(0, 200, 0, 50)
TeleportButton.Position = UDim2.new(0.5, -100, 0.8, 0)
TeleportButton.Text = "Teleportar!"
TeleportButton.TextScaled = true
TeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportButton.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
TeleportButton.Parent = ScreenGui

-- Adiciona o ScreenGui ao jogador
if LocalPlayer:WaitForChild("PlayerGui") then
	ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Função para pegar outro jogador de forma aleatória
local function getRandomPlayer(exceptPlayer)
	local allPlayers = Players:GetPlayers()
	if #allPlayers <= 1 then
		-- Se só existe o jogador local ou nenhum outro, não dá para teleportar
		return nil
	end
	
	local randomPlayer
	repeat
		randomPlayer = allPlayers[math.random(1, #allPlayers)]
	until randomPlayer ~= exceptPlayer
	
	return randomPlayer
end

-- Função que será chamada ao clicar no botão
local function onTeleportButtonClicked()
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	
	local randomP = getRandomPlayer(LocalPlayer)
	if randomP and randomP.Character and randomP.Character:FindFirstChild("HumanoidRootPart") then
		-- Teletransporta o jogador para o outro jogador aleatório
		char:MoveTo(randomP.Character.HumanoidRootPart.Position)
	end
end

-- Conectar evento de clique do botão
TeleportButton.MouseButton1Click:Connect(onTeleportButtonClicked)

----------------------------------------------------------------
-- Parte 1: Desativar colisões somente para este jogador
----------------------------------------------------------------
local function disableCollisionsForCharacter(character)
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
end

-- Sempre que a Character do LocalPlayer for carregada, aplicamos a mudança:
LocalPlayer.CharacterAdded:Connect(function(character)
	-- Esperar Humanoid para ter certeza que está completamente carregado
	local hum = character:WaitForChild("Humanoid")
	
	-- Desativar colisões
	disableCollisionsForCharacter(character)
	
	-- Caso partes sejam adicionadas depois (como acessórios), usar DescendantAdded
	character.DescendantAdded:Connect(function(desc)
		if desc:IsA("BasePart") then
			desc.CanCollide = false
		end
	end)

	----------------------------------------------------------------
	-- Parte 2: Tornar o jogador imortal (não permite HP cair a 0)
	----------------------------------------------------------------
	-- O jogador ainda pode tomar dano e ver a vida diminuir, mas não vai a zero.
	hum.HealthChanged:Connect(function(newHealth)
		if newHealth < 1 then
			hum.Health = 1
		end
	end)

	----------------------------------------------------------------
	-- Parte 3: Aumentar a velocidade do jogador
	----------------------------------------------------------------
	-- Exemplo definindo WalkSpeed para 32 (duas vezes o padrão 16)
	hum.WalkSpeed = 100
end)

-- Se a Character já existir, chamamos manualmente
if LocalPlayer.Character then
	disableCollisionsForCharacter(LocalPlayer.Character)
	local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
	if humanoid then
		-- Forçar a "imortalidade"
		humanoid.HealthChanged:Connect(function(newHealth)
			if newHealth < 1 then
				humanoid.Health = 1
			end
		end)

		-- Aumentar velocidade
		humanoid.WalkSpeed = 32
	end
end