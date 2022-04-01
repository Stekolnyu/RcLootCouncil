-- Author      : Potdisc
-- Create Date : 5/24/2012 6:24:55 PM
-- options.lua - option frame in BlizOptions for RCLootCouncil
local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")

------ Options ------
function addon:OptionsTable()
	local db = addon.db.profile
	local options = { 
		name = "RCLootCouncil",
		type = "group",
		childGroups = "tab",
		args = {
			toggle = {
				order = 1,
				name = "Включить",
				desc = "Включить/выключить аддон.",
				type = "toggle",
				set = function() RCLootCouncil.isRunning() end,
				get = function() return RCLootCouncil:GetVariable("isRunning") end
			},
			toggleAdvanced = {
				order = 2,
				name = "Дополнительные настройки",
				desc = "Включение дополнительных параметров.",
				type = "toggle",
				width = "double",
				get = function() return self.db.profile.advancedOptions end,
				set = function() self.db.profile.advancedOptions = not self.db.profile.advancedOptions; end,
			},
			generalSettingsTab = {
				order = 1,
				type = "group",
				name = "Основные настройки",
				args = {
					addonDesc = {
						order = 1,
						name = "Примечание. Параметры здесь действуют только, если вы являетесь лутером в рейде.\nТолько один параметр можно настроить не имея лутера, \"История добычи\"",
						type = "description",
						hidden = function() return self.db.profile.advancedOptions; end,
					},
					testOptions = {
						order = 2,
						name = "Тестовые настройки",
						type = "group",
						inline = true,
						args = {
							testDesc = {
								order = 1,
								name = "Соло тест запустится локально и с одним элементом.\nРейд тест отобразит вашу конфигурацию для всех в рейде, и позволит голосовать за кого-либо из рейда.\nВ реальном рейде, всегда используется конфигурация мастерлут.\nДля теста с нужным количеством предметов, используйте /rc test (количество предметов).\n",
								type = "description"	
							},
							testButton = {
								order = 2,
								name = "Соло тест",
								desc = "Нажмите, чтобы сымитировать разрол ваших вещей (не требуется рейд)",
								type = "execute",
								func = function()
									InterfaceOptionsFrame:Hide(); -- close all option frames before testing
									RCLootCouncil_Mainframe.testFrames()
								end			
							},
							testRaidButton = {
								order = 3,
								name = "Рейд тест",
								desc = "Нажмите, чтобы сымитировать разрол 5 предметов (требуется рейд и права лидера/помощника)",
								type = "execute",
								func = function()
									if (IsRealRaidLeader() == 1) or (UnitIsRaidOfficer("player") == 1) then
										RCLootCouncil_Mainframe.raidTestFrames(5)
										InterfaceOptionsFrame:Hide();
									else
										addon:Print("Рейдовый тест не может начаться потому что вы не Рейд Лидер/Помощник.")
									end
								end
							},
							versionTest = {
								name = "Проверка версий",
								desc = "Кликните чтобы проверить версии аддона и у кого аддон не установлен",
								type = "execute",
								order = 4,
								func = function()
									RCLootCouncil:EnableModule("RCLootCouncil_VersionFrame");
									InterfaceOptionsFrame:Hide();
								end
							},
						},
					},
					voteOptions = {
						order = 3,
						name = "Настройки голосования\n",
						type = "group",
						inline = true,
						args = {
							selfVoteToggle = {
								order = 1,
								name = "За себя",
								desc = "Отметьте, чтобы разрешить членам рейда голосовать за себя.",
								type = "toggle",
								get = function() return self.db.profile.dbToSend.selfVote end,
								set = function() self.db.profile.dbToSend.selfVote = not self.db.profile.dbToSend.selfVote end,
							},
							multiVoteToggle = {
								order = 2,
								name = "Мультиголосование",
								desc = "Отметьте, чтобы включить множественное голосование, т.е. более одного голоса на игрока.",
								type = "toggle",
								get = function() return self.db.profile.dbToSend.multiVote end,
								set = function() self.db.profile.dbToSend.multiVote = not self.db.profile.dbToSend.multiVote; end,
							},
							allowNotes = {
								order = 3,
								name = "Разрешить заметки",
								desc = "Отметьте, чтобы разрешить рейдерам отправлять запись в рейд со своим ролом.",
								type = "toggle",
								get = function() return self.db.profile.dbToSend.allowNotes end,
								set = function() self.db.profile.dbToSend.allowNotes = not self.db.profile.dbToSend.allowNotes end, 
							},
							anonymousVotingToggle = {
								order = 4,
								name = "Анонимно",
								desc = "Установите флажок, чтобы включить анонимное голосование, т.е. НЕ видеть, кто за кого голосует..",
								type = "toggle",
								hidden = function() return not self.db.profile.advancedOptions; end,
								get = function() return self.db.profile.dbToSend.anonymousVoting end,
								set = function()
									self.db.profile.dbToSend.anonymousVoting = not self.db.profile.dbToSend.anonymousVoting;
									if not self.db.profile.dbToSend.anonymousVoting then 
										self.db.profile.dbToSend.masterLooterOnly = false
									end 
								end,
							},
							masterLooterOnly = {
								order = 5,
								name = "Показать только РЛу",
								desc = "Отметьте, чтобы только РЛ мог видеть тех, кто за кого голосует.",
								type = "toggle",
								disabled = function() return not self.db.profile.dbToSend.anonymousVoting; end,
								hidden = function() return not self.db.profile.advancedOptions; end,
								get = function() return self.db.profile.dbToSend.masterLooterOnly end,
								set = function() self.db.profile.dbToSend.masterLooterOnly = not self.db.profile.dbToSend.masterLooterOnly end,
							},
						},
					},
					lootDesc = {
						order = 4,
						name = "Настройки лутинга",
						type = "group",
						inline = true,
						args = {
							autoLooting = {
								order = 1,
								name = "Авто-лут",
								desc = "Отметьте, чтобы включить авто-лут, т.е. аддон автоматически начинает ролить всякий раз, когда это возможно.",
								type = "toggle";
								get = function() return self.db.profile.autoLooting end,
								set = function() self.db.profile.autoLooting = not self.db.profile.autoLooting; end,
							},
							lootEverything = {
								order = 2,
								name = "Лутать всё",
								desc = "Отметьте, чтобы включить лут не-экипировки (маунтов, токенов)",
								type = "toggle",
								disabled = function() return not self.db.profile.autoLooting; end,
								get = function() return self.db.profile.lootEverything end,
								set = function() self.db.profile.lootEverything = not self.db.profile.lootEverything; end,
							},
							boeLoot = {
								order = 3,
								name = "Авто-лут бое",
								desc = "Отметьте, чтобы включить лут не персональной экипировки.",
								type = "toggle",
								disabled = function() return not self.db.profile.autoLooting; end,
								hidden = function() return not self.db.profile.advancedOptions; end,
								get = function() return self.db.profile.autolootBoE; end,
								set = function() self.db.profile.autolootBoE = not self.db.profile.autolootBoE; end,
							},
							altClickLooting = {
								order = 4,
								name = "Alt+клик",
								desc = "Отметьте, чтобы запустить разрол по нажатию Alt+левый клик.",
								type = "toggle",
								hidden = function() return not self.db.profile.advancedOptions; end,
								get = function() return self.db.profile.altClickLooting end,
								set = function() self.db.profile.altClickLooting = not self.db.profile.altClickLooting; end,
							},
						},
					},
					autoAward = {
						order = 5,
						name = "Качаство предмета",
						type = "group",
						hidden = function() return not self.db.profile.advancedOptions; end,
						inline = true,
						args = {
							autoAward = {
								order = 1,
								name = "Все типы",
								desc = "Отметьте, чтобы включить все типы качества.",
								type = "toggle",
								hidden = function() return not self.db.profile.advancedOptions; end,
								get = function() return self.db.profile.autoAward; end,
								set = function() self.db.profile.autoAward = not self.db.profile.autoAward; end,
							},
							autoAwardQualityLower = {
								order = 1.1,
								name = "Минимальный",
								desc = "Выберите мимимальный уровень качества.\nПРИМЕЧАНИЕ: это переопределит обычный разрол добычи.",
								type = "select",
								style = "dropdown",
								values = function()
									local t = {}
									for i = 0, 5 do
										local r,g,b,hex = GetItemQualityColor(i)
										t[i] = hex.." "..getglobal("ITEM_QUALITY"..i.."_DESC") 
									end
									return t;
								end,
								hidden = function() return not self.db.profile.advancedOptions; end,
								disabled = function() return not self.db.profile.autoAward; end,
								get = function() return self.db.profile.autoAwardQualityLower; end,
								set = function(i,v) self.db.profile.autoAwardQualityLower = v; end,
							},
							autoAwardQualityUpper = {
								order = 1.2,
								name = "Максимальный",
								desc = "Выберите максимальный уровень качества.\nПРИМЕЧАНИЕ: это переопределит обычный разрол добычи.",
								type = "select",
								style = "dropdown",
								values = function()
									local t = {}
									for i = 0, 5 do
										local r,g,b,hex = GetItemQualityColor(i)
										t[i] = hex.." "..getglobal("ITEM_QUALITY"..i.."_DESC") 
									end
									return t;
								end,
								hidden = function() return not self.db.profile.advancedOptions; end,
								disabled = function() return not self.db.profile.autoAward; end,
								get = function() return self.db.profile.autoAwardQualityUpper; end,
								set = function(i,v) self.db.profile.autoAwardQualityUpper = v; end,
							},
							autoAwardTo = {
								order = 2,
								name = "Применить к",
								desc = "Введите имя игрока.",
								width = "double",
								type = "input",
								disabled = function() return not self.db.profile.autoAward; end,
								hidden = function() return not self.db.profile.advancedOptions or IsInRaid(); end,
								get = function() return self.db.profile.autoAwardTo; end,
								set = function(i,v) self.db.profile.autoAwardTo = v; end,
							},
							autoAwardTo2 = {
								order = 2,
								name = "Применить к",
								desc = "Выберите игрока.",
								width = "double",
								type = "select",
								style = "dropdown",
								values = function()
									local t = {}
									if IsInRaid() then
										for i = 1, GetNumGroupMembers() do
											local name = GetRaidRosterInfo(i)
											t[i] = name
										end
									else
										t[1] = UnitName("player");
									end
									return t;
								end,
								disabled = function() return not self.db.profile.autoAward; end,
								hidden = function() return not self.db.profile.advancedOptions or not IsInRaid(); end,
								get = function() return self.db.profile.autoAwardTo; end,
								set = function(i,v) self.db.profile.autoAwardTo = v; end,
							},
							autoAwardReason = {
								order = 2.1,
								name = "Причина",
								desc = "Выберите причину, чтобы добавить в историю добычи.",
								type = "select",
								style = "dropdown",
								values = function()
									local t = {}
									for i = 1, #self.db.profile.otherAwardReasons do
										t[i] = self.db.profile.otherAwardReasons[i].text
									end
									return t
								end,
								disabled = function() return not self.db.profile.autoAward; end,
								hidden = function() return not self.db.profile.advancedOptions; end,
								get = function() return self.db.profile.autoAwardReason; end,
								set = function(i,v) self.db.profile.autoAwardReason = v; end,
							},
						},
					},
				},
			},
			announcementTab = {
				order = 2,
				type = "group",
				name = "Настройки объявлений",
				hidden = function() return not self.db.profile.advancedOptions; end,
				args = {
					AwardAnnouncement = {
						order = 1,
						name = "Объявления",
						type = "group",
						inline = true,
						args = {
							toggle = {
								order = 1,
								name = "Включить",
								desc = "Включить/выключить.",
								type = "toggle",
								width = "full",
								get = function() return self.db.profile.awardAnnouncement end,
								set = function() self.db.profile.awardAnnouncement = not self.db.profile.awardAnnouncement; end,
							},
							outputDesc = {
								order = 2,
								name = "\nВыберите, нужно ли объявить, кому вручается предмет, какое сообщение вы хотите объявить, на каком канале при вручении добычи, или нет, чтобы отключить объявление. Вы можете объявить сразу по 2 каналам.\nИспользуйте &p для имени игрока, получающего добычу, и &i для присуждаемого предмета.",
								type = "description",
							},
							outputMessage = {
								order = 3,
								name = "Первый канал",
								desc = "Сообщение будет отправлено при победе игрока.",
								type = "input",
								width = "double",
								get = function() return self.db.profile.awardMessageText1 end,
								set = function(i,v) self.db.profile.awardMessageText1 = v; end,
								hidden = function() return not self.db.profile.awardAnnouncement; end,
							},
							outputSelect = {
								order = 3.1,
								name = "",
								desc = "Выберите канал, чтобы объявить победителя.",
								type = "select",
								style = "dropdown",
								values = {
									NONE = "Нет",
									SAY = "Сказать",
									YELL = "Крик",
									PARTY = "Группа",
									GUILD = "Гильдия",
									OFFICER = "Офицерский канал",
									RAID = "Рейд",
									RAID_WARNING = "Рейд-предупреждение"
								},
								set = function(i,v) self.db.profile.awardMessageChat1 = v end,
								get = function() return self.db.profile.awardMessageChat1 end,
								hidden = function() return not self.db.profile.awardAnnouncement; end,
							},
							outputMessage2 = {
								order = 4,
								name = "Второй канал",
								desc = "Сообщение будет отправлено при победе игрока.",
								type = "input",
								width = "double",
								get = function() return self.db.profile.awardMessageText2 end,
								set = function(i,v) self.db.profile.awardMessageText2 = v; end,
								hidden = function() return not self.db.profile.awardAnnouncement; end,
							},
							outputSelect2 = {
								order = 4.1,
								name = "",
								desc = "Выберите канал, чтобы объявить победителя.",
								type = "select",
								style = "dropdown",
								values = {
									NONE = "Нет",
									SAY = "Сказать",
									YELL = "Крик",
									PARTY = "Группа",
									GUILD = "Гильдия",
									OFFICER = "Офицерский канал",
									RAID = "Рейд",
									RAID_WARNING = "Рейд-предупреждение"
								},
								set = function(i,v) self.db.profile.awardMessageChat2 = v end,
								get = function() return self.db.profile.awardMessageChat2 end,
								hidden = function() return not self.db.profile.awardAnnouncement; end,
							},
						},
					},				
					
					considerationAnnouncement = {
						order = 2,
						name = "Объявление о рассмотрении",
						type = "group",
						inline = true,
						args = {
							announceConsideration = {
								order = 1,
								name = "Объявить рассмотрение",
								desc = "Проверьте, чтобы включить объявление о рассмотрении предметов.",
								type = "toggle",
								width = "full",
								get = function() return self.db.profile.announceConsideration; end,
								set = function() self.db.profile.announceConsideration = not self.db.profile.announceConsideration; end,
							},
							desc = {
								order = 2,
								type = "description",
								name = "\nВыберите, хотите ли вы объявлять каждый раз, когда предмет находится на рассмотрении, какой канал объявлять и какое сообщение объявлять..\nИспользуйте &i для отображения рассматриваемого предмета.",
							},							
							announceText = {
								order = 3,
								name = "Объявить рассмотрение",
								desc = "Сообщение отобразится, когда предмет находится на рассмотрении.",
								type = "input",
								width = "double",
								get = function() return self.db.profile.announceText end,
								set = function(i,v) self.db.profile.announceText = v; end,
								hidden = function() return not self.db.profile.announceConsideration; end,
							},
							announceChannel = {
								order = 3.1,
								name = "",
								desc = "Канал для отправки сообщения.",
								type = "select",
								style = "dropdown",
								values = {
									SAY = "Сказать",
									YELL = "Крик",
									PARTY = "Группа",
									GUILD = "Гильдия",
									OFFICER = "Офицерский канал",
									RAID = "Рейд",
									RAID_WARNING = "Рейд-предупреждение"
								},
								set = function(i,v) self.db.profile.announceChannel = v end,
								get = function() return self.db.profile.announceChannel end,
								hidden = function() return not self.db.profile.announceConsideration; end,
							},
						},
					},
					reset = {
						order = -1,
						name = "Сброс",
						desc = "Сброс всех настроек объявления на значение по умолчанию",
						type = "execute",
						confirm = true,
						func = function() addon:announceToDefault() end
					},
				},
			},
			buttonsOptionsTab = {
				order = 3,
				type = "group",
				name = "Настройки кнопок",
				hidden = function() return not self.db.profile.advancedOptions; end,
				args = {
					buttonOptions = {
						order = 1,
						type = "group",
						name = "Кнопки и ответы",
						inline = true,
						args = {
							optionsDesc = {
								order = 0,
								name = "Настройте кнопки ответа а окне разрола, а также свой ответ и цвет.\nКнопки располагаются слева на право. Используйте ползунок, чтобы выбрать количество кнопок (всего "..self.db.profile.dbToSend.maxButtons..").\n\nПервая кнопка всегда активна и будет учитываться как МейнСпек в истории лута.\nВы должны указать новую кнопку \"Pass\", если вы ее измените.",
								type = "description"
							},
							buttonsRange = {
								order = 1,
								name = "Количество кнопок",
								desc = "Сдвиньте, чтобы выбрать количество кнопок в окне разрола.",
								type = "range",
								width = "full",
								min = 1,
								max = self.db.profile.dbToSend.maxButtons,
								step = 1,
								get = function() return self.db.profile.dbToSend.numButtons; end,
								set = function(i,v) self.db.profile.dbToSend.numButtons = v; end,
							},
							passButton = {
								order = -1,
								name = "Пасс",
								desc = "Выберите расположение кнопки Пасс, чтобы иметь возможность отфильтровать спасовавших при разроле.",
								type = "select",
								style = "dropdown",
								width = "double",
								values = function()
									local t = {}
									t[(self.db.profile.dbToSend.maxButtons + 1)] = "Нет";
									for i = 1, self.db.profile.dbToSend.maxButtons do
										if i <= self.db.profile.dbToSend.numButtons then t[i] = "Кнопка "..i; else break; end
									end	
									return t;
								end,
								set = function(i,v) self.db.profile.dbToSend.passButton = v end,
								get = function() return self.db.profile.dbToSend.passButton end,
							},
						},
					},
					whisperOptions = {
						order = 2,
						type = "group",
						name = "Настройки шепота",
						inline = true,
						args = {							
							acceptWhispers = {
								order = 1,
								name = "Разрешить шепот",
								desc = "Разрешить игрокам без аддона, шептать вам их текущую ставку, чтобы добавить их в список рассмотрения.",
								type = "toggle",
								get = function() return self.db.profile.acceptWhispers end,
								set = function() self.db.profile.acceptWhispers = not self.db.profile.acceptWhispers end,
							},
							acceptRaidChat = {
								order = 1.1,
								name = "Разрешить рейд чат",
								desc = "Разрешить игрокам без аддона, писать в рейд чат их текущую ставку, чтобы добавить их в список рассмотрения.",
								type = "toggle",
								get = function() return self.db.profile.acceptRaidChat end,
								set = function() self.db.profile.acceptRaidChat = not self.db.profile.acceptRaidChat; end,
							},
							desc = {
								order = 2,
								name = "Чтобы быть добавленным в список рассмотрения, без установки надстройки рейдеры могут связать свои предметы, за которыми следует ключевое слово, с Master Looter (кнопка 1 используется, если ключевое слово не указано).\nПример: \"/w ML_NAME [ITEM] greed\" будет по умолчанию отображаться, когда вы нидите предмет.\nНиже вы можете выбрать ключевые слова для отдельных кнопок, разделенные знаками препинания или пробелами. Принимаются только числа и слова.\nИгроки могут получить список ключевых слов, отправив сообщение rchelp лутеру после включения аддона (т.е. в рейде).",
								type = "description",
							},
						},
					},
					reset = {
						order = -1,
						name = "Сбросить",
						desc = "Сбрасывает все кнопки, цвета и ответы на значения по умолчанию",
						type = "execute",
						confirm = true,
						func = function() addon:buttonsToDefault() end
					},
				},
			},
			lootHistoryTab = {
				order = 4,
				type = "group",
				name = "Настройки истории",
				hidden = function() return not self.db.profile.advancedOptions; end,
				args = {
					lootHistoryOptions = {
						order = 1,
						type = "group",
						name = "История разрола",
						inline = true,
						args = {
							desc1 = {
								order = 1,
								name = "История добычи все еще находится в стадии разработки — на данный момент она регистрирует все данные и отображает их в простом представлении..\n",
								type = "description",
							},
							trackLooting = {
								order = 2,
								name = "Запись лога",
								desc = "Отметьте, чтобы включить отслеживание лута. Работает только для не-лутера, если мастерлут включил \"Отправить лог\".",
								type = "toggle",
								get = function() return self.db.profile.trackAwards; end,
								set = function() self.db.profile.trackAwards = not self.db.profile.trackAwards; end,
							},
							sendHistory = {
								order = 3,
								name = "Отправить лог",
								desc = "Отметьте, чтобы отправить лог каждому в игроку в рейде, независимо от того ваш он или нет. Любой участник рейда с включенной функцией \"Запись лога\" получит ту же информацию, что и вы.",
								type = "toggle",
								width = "full",
								get = function() return self.db.profile.sendHistory; end,
								set = function() self.db.profile.sendHistory = not self.db.profile.sendHistory; end,
							},
							openLootDB = {
								order = 4,
								name = "Открыть историю",
								desc = "Нажмите, чтобы открыть историю добычи.",
								type = "execute",
								func = function() RCLootCouncil:EnableModule("RCLootHistory");	InterfaceOptionsFrame:Hide();end,
							},
							clearLootDB = {
								order = 90,
								name = "Очистить историю",
								desc = "Удалить всю историю добычи.",
								type = "execute",
								func = function() self.db.factionrealm.lootDB = {} end,
								confirm = true,
							},
						},
					},
					awardOptions = {
						order = 2,
						type = "group",
						name = "Другие записи истории",
						inline = true,
						args = {
							desc = {
								order = 0,
								name = "Другие причины для присуждения предметов, кроме обычного ролла.\nИспользуется в меню правой кнопкой мыши.\n",
								type = "description",
							},
							range = {
								order = 1,
								name = "Количество причин",
								desc = "Сдвиньте, чтобы выбрать количество причин, которые можно использовать в меню правой кнопкой мыши.",
								type = "range",
								width = "full",
								min = 1,
								max = 8,
								step = 1,
								get = function() return #self.db.profile.otherAwardReasons; end,
								set = function(i,v)
									if v < #self.db.profile.otherAwardReasons then
										tremove(self.db.profile.otherAwardReasons)
									elseif v > #self.db.profile.otherAwardReasons then
										tinsert(self.db.profile.otherAwardReasons, { text = "", log = true,})
									end
								end,
							},
							reset = {
								order = -1,
								name = "Сбросить",
								desc = "Сбрасывает настройки этого раздела, на значения по умолчанию.",
								type = "execute",
								confirm = true,
								func = function() addon:otherAwardReasonsToDefault() end, 
							},
						},
					},
				},
			},
			council = {
				order = 5,
				type = "group",
				name = "Рейд",
				childGroups = "tab",
				args = {
					currentCouncil = {
						order = 1,
						type = "group",
						name = "Текущий рейд",
						args = {
							currentCouncilDesc = {
								order = 1,
								name = "\nНажмите, чтобы удалить определенных игроков из разрола\n",
								type = "description",
							},
							councilList = {
								order = 2,
								type = "multiselect",
								name = "",
								values = function()
									local t = {}
									for k,v in ipairs(self.db.profile.council) do t[k] = ""..v end
									return t;
								end,
								width = "full",
								get = function() return true end,
								set = function(m,key) tremove(self.db.profile.council,key) end,
							},							
							removeAll = {
								order = 3,
								name = "Удалить всех",
								desc = "Удалить всех членов рейда",
								type = "execute",
								confirm = true,
								func = function() self.db.profile.council = {} end,							
							},
						},
					},
					addCouncil = {
						order = 2,
						type = "group",
						name = "Редактировать",
						childGroups = "tree",
						args = {
							addRank = {
								order = 1,
								name = "Добавить звание",
								type = "group",
								args = {
									header1 = {
										order = 1,
										name = "Минимальное звание для участия в разроле:",
										type = "header",
										width = "full",
									},
									selection = {
										order = 2,
										name = "",
										type = "select",
										width = "full",
										values = function()
											GuildRoster();
											local info = {};
											for ci = 1, GuildControlGetNumRanks() do 
												info[ci] = " "..ci.." - "..GuildControlGetRankName(ci);
											end
											return info
										end,
										set = function(j,i) self.db.profile.council = {}; RCLootCouncil_Mainframe.setRank(i); end,
										get = function() return self.db.profile.minRank; end,
									},
									desc = {
										order = 3,
										name = "\n\nВыберите минимальное звание, от которого игроки могут претендовать на лут.\n\nНажмите на звания слева, чтобы добавить отдельных игроков в группу.\n\nПерейдите на вкладку 'Текущий рейд', чтобы увидеть ваш состав.",
										type = "description",
									},
								},
							},
							spacer = {
								order = 2,
								name = "",
								type = "group",
								args = {}
							},
						},
					},
				},
			},
		},
	}
	
	-- make the buttons config
	local button, picker, text = {}, {}, {}
	for i = 1, self.db.profile.dbToSend.maxButtons do	
		button = {
			order = i * 3 + 1,
			name = "Кнопка "..i,
			desc = "Введите текст "..i..".",
			type = "input",
			get = function() return self.db.profile.dbToSend.buttons[i]["text"] end,
			set = function(info, value)	self.db.profile.dbToSend.buttons[i]["text"] = tostring(value) end,
			hidden = function() if self.db.profile.dbToSend.numButtons < i then return true; else return false; end end
		}
		options.args.buttonsOptionsTab.args.buttonOptions.args["button"..i] = button;
		picker = {
			order = i * 3 + 1,
			name = "Цвет ответа",
			desc = "Выберите цвет",
			type = "color",
			get = function()
				local r = self.db.profile.dbToSend.buttons[i]["color"][1]
				local g = self.db.profile.dbToSend.buttons[i]["color"][2]
				local b = self.db.profile.dbToSend.buttons[i]["color"][3]
				return r,g,b
			end,
			set = function(info,r,g,b)
				local color = {r,g,b,1}
				self.db.profile.dbToSend.buttons[i]["color"] = color
			end,
			hidden = function() if self.db.profile.dbToSend.numButtons < i then return true; else return false; end end,
		}
		options.args.buttonsOptionsTab.args.buttonOptions.args["picker"..i] = picker;
		text = {	
			order = i * 3 + 3,
			name = "Ответ",
			desc = "Введите текст для "..i.." кнопки.",
			type = "input",
			get = function() return self.db.profile.dbToSend.buttons[i]["response"] end,
			set = function(info, value) self.db.profile.dbToSend.buttons[i]["response"] = tostring(value) end,
			hidden = function() if self.db.profile.dbToSend.numButtons < i then return true; else return false; end end,		
		}
		options.args.buttonsOptionsTab.args.buttonOptions.args["text"..i] = text;
		local whisperKeys = {
			order = i + 3,
			name = "Кнопка "..i,
			desc = "Введите ключевые слова для шепота "..i..".",
			type = "input",
			width = "double",
			get = function() return self.db.profile.dbToSend.buttons[i]["whisperKey"] end,
			set = function(k,v) self.db.profile.dbToSend.buttons[i]["whisperKey"] = v end,
			hidden = function() if self.db.profile.dbToSend.numButtons < i or not self.db.profile.acceptWhispers then return true; else return false; end end,
		}
		options.args.buttonsOptionsTab.args.whisperOptions.args["whisperKey"..i] = whisperKeys;
	end
	for i = 1, 8 do
		options.args.lootHistoryTab.args.awardOptions.args["reason"..i] = {
			order = i * 2 +1,
			name = "Причина "..i,
			desc = "Введите причину #"..i,
			type = "input",
			width = "double",
			get = function() return self.db.profile.otherAwardReasons[i].text end,
			set = function(k,v) self.db.profile.otherAwardReasons[i].text = v; end,
			hidden = function() if #self.db.profile.otherAwardReasons < i then return true; else return false; end end,
		}
		
		options.args.lootHistoryTab.args.awardOptions.args["log"..i] = {
			order = i * 2 +2,
			name = "Лог",
			desc = "Добавить в историю добычи?",
			type = "toggle",
			get = function() return self.db.profile.otherAwardReasons[i].log end,
			set = function() self.db.profile.otherAwardReasons[i].log = not self.db.profile.otherAwardReasons[i].log end,
			hidden = function() if #self.db.profile.otherAwardReasons < i then return true; else return false; end end,
		}
	end
	return options
end

function RCLootCouncil:GetGuildOptions()
	for i = 1, GuildControlGetNumRanks() do
		local rank = GuildControlGetRankName(i)
		local names = {}

		-- Define the individual council option:
		local option = {
			order = i + 2,
			name = rank,
			type = "group",
			args = {
				ranks = {
					order = i,
					name = ""..rank,
					type = "multiselect",
					width = "full",
					values = function()
						wipe(names)
						for ci = 1, GetNumGuildMembers() do
							local name, rank1, rankIndex = GetGuildRosterInfo(ci);
							-- no need to diff it for pservers
							-- name = Ambiguate(name, "none")
							if (rankIndex + 1) == i then tinsert(names, name) end
						end
						table.sort(names, function(v1, v2)
							return v1 and v1 < v2
						end)
						return names
					end,
					get = function(info, number)
						local values = addon.options.args.council.args.addCouncil.args[info[#info-1]].args.ranks.values()
						for j = 1, #self.db.profile.council do
							if values[number] == self.db.profile.council[j] then return true end
						end
						return false
					end,
					set = function(info, number, tag)
						local values = addon.options.args.council.args.addCouncil.args[info[#info-1]].args.ranks.values()
						if tag then tinsert(self.db.profile.council, values[number])
						else
							for k,v in ipairs(self.db.profile.council) do
								if v == values[number] then
									tremove(self.db.profile.council, k)
								end
							end
						end
					end,
				},
			},
		}

		-- Add it to the guildMembersGroup arguments:
		self.options.args.council.args.addCouncil.args[i..""..rank] = option
	end
end
