/client/verb/who()
	set name = "Who"
	set category = "OOC"

	var/msg = "<meta charset='UTF-8'><b>Список ваших товарищей:</b>\n"

	var/list/Lines = list()

	var/living = 0
	var/dead = 0
	var/observers = 0
	var/lobby = 0
	var/living_antags = 0
	var/dead_antags = 0

	if(check_rights(R_INVESTIGATE, 0))
		log_admin("[key_name(usr)] checked advanced who in-round.")
		for(var/client/C in GLOB.clients)
			var/entry = "\t[C.key]"
			if(!C.mob) //If mob is null, print error and skip rest of info for client.
				entry += " - <font color='red'><i>НЕ ИМЕЕТ ТЕЛА!</i></font>"
				Lines += entry
				continue

			if(isghost(C.mob))
				entry += " - <font color='gray'><b>Наблюдает</b></font> как <b>[C.mob.real_name]</b>"
			else if(isliving(C.mob))
				entry += " - <font color='green'><b>Играет</b></font> за <b>[C.mob.real_name]</b>"

			switch(C.mob.stat)
				if(UNCONSCIOUS)
					entry += " - <font color='#404040'><b>Бессознания</b></font>"
					living++
				if(DEAD)
					if(isghost(C.mob))
						var/mob/observer/ghost/O = C.mob
						if(O.started_as_observer)
							observers++
						else
							entry += " - <b>МЁРТВ</b>"
							dead++
					else if(isnewplayer(C.mob))
						entry += " - <font color='#006400'><b>В лобби</b></font>"
						lobby++
					else
						entry += " - <b>МЁРТВ</b>"
						dead++
				else
					living++

			if(isnum(C.player_age))
				var/age = C.player_age

				if(age <= 1)
					age = "<font color='#ff0000'><b>[age]</b></font>"
				else if(age < 10)
					age = "<font color='#ff8c00'><b>[age]</b></font>"

				entry += " - [age]"

			if(is_special_character(C.mob))
				entry += " - <b><font color='red'>Антагонист</font></b>"
				if(!C.mob.mind.current || C.mob.mind.current?.stat == DEAD)
					dead_antags++
				else
					living_antags++

			if(C.is_afk())
				entry += " - <b>AFK: [C.inactivity2text()]</b>"
			entry += " (<A HREF='?_src_=holder;adminmoreinfo=\ref[C.mob]'>?</A>)"
			Lines += entry
	else
		for(var/client/C in GLOB.clients)
			if(!C.is_stealthed())
				var/entry = "\t[C.key]"
/*				switch(C.mob.stat)
					if(DEAD)
						if(isghost(C.mob))
							var/mob/observer/ghost/O = C.mob
							if(O.started_as_observer)
								entry += " - <font color='gray'><b>Наблюдает</b></font>"
							else
								entry += " - <font color='green'><b>Играет</b></font>"
						else if(isnewplayer(C.mob))
							entry += " - <font color='#006400'><b>В лобби</b></font>"
					else
						entry += " - <font color='green'><b>Играет</b></font>"*/

				if(C.is_afk())
					entry += " - <b>AFK: [C.inactivity2text()]</b>"

				Lines += entry

	if(get_preference_value(/datum/client_preference/window_who) == GLOB.PREF_YES)
		msg = "<h2><b>Список ваших товарищей:</b></h2>\n"

	for(var/line in sortList(Lines))
		msg += "[line]\n"

	if(check_rights(R_INVESTIGATE, 0))
		msg += "<b><font color='green'>Живые: [living]</font> | Мёртвые: [dead] | <font color='gray'>Наблюдают: [observers]</font> | <font color='#006400'>Лобби: [lobby]</font> | <font color='#8100aa'>Живых антагонисты: [living_antags]</font> | <font color='#9b0000'>Мёртвые антагонисты: [dead_antags]</font></b>\n"

	msg += "<b>Всего товарищей: [length(Lines)]</b>"
	if(get_preference_value(/datum/client_preference/window_who) == GLOB.PREF_YES)
		msg = replacetext(msg, "\n", "<br>")
		show_browser(usr, msg, "window=who;size=780x420;can_close=1")
	else
		to_chat(src, msg)

/datum/client_preference/window_who
	description ="Who: Show in a separate window"
	key = "WINDOW_WHO"
	default_value = GLOB.PREF_NO
