//Written by P53 and Zac

state("LEGOStarWarsSaga")
{
    uint gogstatus : 0x550790;
    byte status : 0x526BD0;
    byte statust : 0x481C38;
    byte newgame : 0x47B738;
    byte gognewgame : 0x47b758;
    byte posb : 0x40B708;
    byte posc : 0x40B70C;
    string12 stream : 0x4CBB90;
    int gogstream : 0x551bc0;
    float wipe : 0x5507a0;
    //This is our second variable that is an int that references address 0x5513d0
    int variable2 : 0x5513d0;
    //This is our third variable that is a short that references address 0x5513d0,0xf0
    short variable3 : 0x5513d0,0xf0;
    short jedibattlewave : 0x488ef4;
    //This is a lapcount that can land in the water
    float lapcount : 0x4824a0,0x28;
    int mapaddr : 0x402c54;
    int kitcount : 0x00551264;
    short incutscene : 0x551c54;
}

state("LEGOStarWarsSaga.exe.unpacked")
{
    byte status : 0x526BD0;
    byte statust : 0x481C38;
    byte newgame : 0x47B738;
    byte posb : 0x40B708;
    byte posc : 0x40B70C;
    string12 stream : 0x4CBB90;
}

init{
    vars.levelend = false;
    vars.lastroom = 0;
    vars.mystery193 = new byte[43]{0x38,0x3c,0x78,0xc0,0x11,0x7e,0x7c,0xca,0x87,0xf,0xfc,0x64,0x33,0x54,0x7f,0xf4,0x38,0x87,0x32,0x1e,0x3e,0x3e,0xf0,0x79,0xe0,0xa3,0xe0,0xe3,0xc3,0xc7,0x87,0xe3,0x28,0x1e,0x4e,0x1e,0xff,0x18,0x5,0x55,0x5,0x47,0x0};
	vars.levellookup = new byte[43]{0x80,0x80,0x0,0x1,0x28,0x0,0x81,0x14,0x10,0x40,0x0,0x91,0x84,0xa8,0x0,0xa,0x41,0x8,0x45,0x80,0x80,0x0,0x2,0x2,0x1,0x48,0x1,0x8,0x10,0x10,0x10,0x8,0x52,0x80,0xa0,0x40,0x0,0x22,0xaa,0xaa,0x1a,0x20,0x0};
}

startup
{
    settings.Add("splitdelay", true, "Using the steam or steamless .exe. Only features simple capabilities. Boxes below are not supported on steam or steamless.");
    settings.Add("any", true, "Category: Any%");
    settings.Add("fp", false, "Category: Free Play");
    settings.Add("challenges", false, "Category: All Challenges");
    settings.Add("am", false, "Category: All Minikits");
    settings.Add("prequels1", false, "Category: Prequels (End on Maul)");
    settings.Add("prequels3", false, "Category: Prequels (End on Vader)");
    settings.Add("mkrush", false, "Category: Minikit Rush");
    settings.Add("il", false, "Category: Story IL (Start on room change)");
    settings.Add("GOG", false, "Using the GOG .exe. Features beyond simple capabilities will only be activated if this box is enabled.");
    settings.Add("rooms", false, "Split on every room.");
    settings.Add("cantina", false, "Split on every room in the cantina.");
    settings.Add("kits", false, "Split on every kit in All Challenges.");
    settings.Add("invasion", false, "Start and stop at the beginning and end of the first room of Invasion.");

    vars.stopwatch = new Stopwatch();
    refreshRate = 255;
    vars.splitActions = (EventHandler)((s, e) => {
        vars.stopwatch.Reset();
    });
    timer.OnSplit += vars.splitActions;
}

split
{
    if (!settings["GOG"]){
        if (settings["splitdelay"] && current.status > old.status && current.statust != old.statust) vars.stopwatch.Restart();
        if (vars.stopwatch.ElapsedMilliseconds > 767) return true;
        if (settings["any"] && current.posb == 90 && current.posc == 180 && current.stream == "Escape_Outro") return true;
    }
    else {
        if (settings["invasion"] && current.mapaddr != old.mapaddr) return true;
        else if(settings["invasion"]) return false;
        if (current.gogstream == 110) return false;
        if ((settings["fp"] || settings["challenges"] || settings["prequels1"]) && current.gogstream == 55 && old.gogstream == 55) return false;
        else if ((settings["am"] || settings["prequels3"]) && current.gogstream == 139) return false;
        else if(((vars.levellookup[current.gogstream >> 3] & (1 << (current.gogstream & 7))) != 0) && old.wipe != 0 && current.wipe == 0){
            return true;
        }
        if (settings["any"] && current.gogstream == 250 && old.gogstream == 249) return true;
        else if (settings["fp"] && current.gogstream == 55 && old.gogstream == 54) return true;
        else if (settings["prequels1"] && current.incutscene == 1 && old.incutscene == 0 && current.gogstream == 54) return true;
        else if (settings["challenges"] && current.gogstream == 54 && current.kitcount == 10 && old.kitcount == 9) return true;
        else if ((settings["am"] || settings["prequels3"]) && current.gogstream == 138 && current.incutscene == 1 && old.incutscene == 0) return true;
        if (settings["kits"] && old.kitcount < current.kitcount) return true;
        if (settings["rooms"] && (((old.variable2 != current.variable2 && ((vars.mystery193[current.variable3 >> 3] & (1 << (current.variable3 & 7))) != 0)) || (current.gogstream == 90 && old.jedibattlewave != current.jedibattlewave && current.jedibattlewave > 3) || (current.gogstream == 36 && current.lapcount == 3 && old.lapcount < 3) || (vars.lastroom == 325 && old.mapaddr != current.mapaddr && (settings["any"] || settings["prequels1"] || settings["am"] || settings["prequels3"] || settings["mkrush"]))) && current.gogstream != 325 || (current.gogstream == 137 && old.gogstream == 136) || (current.gogstream == 230 && old.gogstream == 233) || (current.gogstream == 234 && old.gogstream == 233) || (current.gogstream == 289 && old.gogstream == 288 && old.wipe == 0) || (current.gogstream == 295 && old.gogstream == 288) || (current.gogstream == 292 && old.gogstream == 291) || (current.gogstream == 138 && old.gogstream == 137))) return true;
        if (settings["cantina"] && (current.gogstream == 325 && current.wipe > 0 && old.wipe == 0 && old.mapaddr == current.mapaddr)) return true;
    }
	return false;
}

start
{
    if (!settings["GOG"]){
        return current.newgame == 1 && old.newgame == 0;
    }
    else{
        if(settings["any"] || settings["am"] || settings["prequels1"] || settings["prequels3"]){
            return current.gognewgame == 1 && old.gognewgame == 0;
        }
        else if(settings["fp"]){
            return current.gogstream == 299 && old.mapaddr != current.mapaddr;
        }
        else if(settings["challenges"]){
            return current.gogstream == 288 && old.mapaddr != current.mapaddr;
        }
        else if(settings["il"]){
            return old.mapaddr != current.mapaddr;
        }
        else if(settings["mkrush"]){
            return current.gogstream == 288 && old.mapaddr != current.mapaddr;
        }
        else if(settings["invasion"]){
            return current.gogstream == 10 && old.gogstream == 9;
        }
    }
}

reset
{
    if (settings["GOG"] && (settings["any"] || settings["prequels1"] || settings["prequels3"])){
        return old.gogstream == 325 && current.gogstream == 0;
    }
}

update{
    if(!vars.levelend){
        vars.levelend = current.status > old.status;
    }
    else if(current.status == 0){
        vars.levelend = false;
    }
    if (current.gogstream != old.gogstream) vars.lastroom = old.gogstream;
	return true;
}