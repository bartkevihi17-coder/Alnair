from pathlib import Path
p=Path(r"C:\Users\bartk\Desktop\Alnair\src\shared\Appearance.lua")
s=p.read_text("utf-8")
needle='''            rig.Parent = parent
            return rig'''
assert needle in s
new='''            rig.Parent = parent
            -- Pose natural no menu: os meshes R15 chegam do Studio em T-pose.
            -- Mover a cadeia inteira em torno da articulacao anatomica real.
            local function poseChain(parentPart,jointName,names,angle)
                local host=rig:FindFirstChild(parentPart)
                local hinge=host and host:FindFirstChild(jointName)
                if not hinge or not hinge:IsA("Attachment") then return end
                local point=hinge.WorldPosition
                local rotate=CFrame.new(point)*CFrame.Angles(0,0,angle)*CFrame.new(-point)
                for _,pieceName in ipairs(names) do
                    local limb=rig:FindFirstChild(pieceName)
                    if limb and limb:IsA("BasePart") then
                        limb.CFrame=rotate*limb.CFrame
                    end
                end
            end
            poseChain("UpperTorso","LeftShoulderRigAttachment",
                {"LeftUpperArm","LeftLowerArm","LeftHand"},math.rad(73))
            poseChain("UpperTorso","RightShoulderRigAttachment",
                {"RightUpperArm","RightLowerArm","RightHand"},math.rad(-73))
            poseChain("LowerTorso","LeftHipRigAttachment",
                {"LeftUpperLeg","LeftLowerLeg","LeftFoot"},math.rad(-4))
            poseChain("LowerTorso","RightHipRigAttachment",
                {"RightUpperLeg","RightLowerLeg","RightFoot"},math.rad(4))
            return rig'''
s=s.replace(needle,new,1)
p.write_text(s,"utf-8",newline="\n")
print("PREVIEW A-POSE STANDING",len(s))
