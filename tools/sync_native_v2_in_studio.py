"""Update already open Alnair-NATIVE-R6-TEST.rbxl via official Studio MCP.
Never start a new Roblox Studio process. Works in Edit mode only.
"""
from pathlib import Path
import json,sys,importlib.util,time
sys.stdout.reconfigure(encoding="utf-8",errors="replace")
base=Path(r"C:\Users\bartk\Desktop\Alnair")
spec=importlib.util.spec_from_file_location("bridge",base/"tools/roblox_studio_mcp_bridge.py")
bridge=importlib.util.module_from_spec(spec)
spec.loader.exec_module(bridge)
session=bridge.Session()
try:
    studios=bridge.data(session.call("list_roblox_studios"))
    matches=[s for s in studios.get("studios",[]) if s.get("file")=="Alnair-NATIVE-R6-TEST.rbxl" and s.get("mode")=="Edit"]
    if len(matches)!=1:raise RuntimeError("Expected exactly one open Alnair edit session, got "+repr(studios))
    studio_id=matches[0]["id"]
    print("STUDIO_ID",studio_id,"EXISTING_SESSION",flush=True)
    def patch(file,edits):
        if not edits:raise ValueError(file)
        result=session.call("multi_edit",{"studio_id":studio_id,"datamodel_type":"Edit",
            "file_path":file,"edits":[{"old_string":old,"new_string":new}for old,new in edits]},timeout=55)
        if result.get("isError"):raise RuntimeError(file+" "+str(bridge.data(result))[:900])
        print("PATCHED",file,bridge.data(result),flush=True)

    catalog=(base/"src/shared/Catalog.lua").read_text(encoding="utf-8")
    insertion=catalog[catalog.index("-- Cada raça"):catalog.index("function Catalog.findOption")]
    patch("ReplicatedStorage.AlnairShared.Catalog",[
        ("function Catalog.findOption(group, id)",insertion+"function Catalog.findOption(group, id)"),
        ("    local appearance = {}\n    local supplied = typeof(payload.appearance)",
         "    local appearance = {}\n    local defaults=Catalog.defaultsForRace(race)\n    local supplied = typeof(payload.appearance)"),
        ("            value = Catalog.DefaultAppearance[group]","            value = defaults[group]")
    ])
    app=(base/"src/shared/Appearance.lua").read_text(encoding="utf-8")
    update=app[app.index("    model:PivotTo(CFrame.new(0,2.85,0))"):app.index("    return model\nend\n\nreturn Appearance")]
    patch("ReplicatedStorage.AlnairShared.Appearance",[
        ("    return model\nend\n\nreturn Appearance",update+"    return model\nend\n\nreturn Appearance")
    ])
    client=(base/"src/client/Alnair.client.luau").read_text(encoding="utf-8")
    begin=client.index("        applyView()\n        local elapsed=0\n")
    finish=client.index("        end)\n    end)\nend\nlocal function clearArea()",begin)
    replacement=client[begin:finish+len("        end)")]
    old="""        applyView()
        previewConnection=RunService.RenderStepped:Connect(function(dt)
            if not previewFrame or not previewFrame.Parent then return end
            yaw+=math.min(dt,.05)*.17
            applyView()
        end)"""
    # RenderStepped patch. Source in Studio is v1 code, not the current v2.
    patch("StarterPlayer.StarterPlayerScripts.AlnairClient.Alnair",[
        (old,replacement),
        ("            selected.race=id;showRace()",
         "            if selected.race~=id then\n"
         "                selected.race=id\n"
         "                selected.appearance=Catalog.defaultsForRace(id)\n"
         "            end\n"
         "            showRace()"),
        ("            selected.class=id;showClass()",
         "            if selected.class~=id then\n"
         "                selected.class=id\n"
         "                local preset=Catalog.ClassOutfits[id]\n"
         "                if preset then\n"
         "                    selected.appearance.upper=preset.upper\n"
         "                    selected.appearance.lower=preset.lower\n"
         '                    selected.appearance.set="none"\n'
         "                end\n"
         "            end\n"
         "            showClass()"),
    ])
    saved=session.call("save_place",{"studio_id":studio_id},timeout=55)
    if saved.get("isError"):raise RuntimeError("save_place: "+str(bridge.data(saved)))
    print("SAVE_PLACE",str(bridge.data(saved))[:950],flush=True)
    print("NATIVE_R6_STUDIO_PATCH_SUCCESS",flush=True)
finally:session.close()
