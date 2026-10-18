local meta = FindMetaTable("Entity")

if not meta._hmcdOrigFireBullets then
    meta._hmcdOrigFireBullets = meta.FireBullets
end
local oldFireBullets = meta._hmcdOrigFireBullets

function meta:FireBullets(bullet, ...)
    if istable(bullet) then
        if bullet.Spread ~= nil and not isvector(bullet.Spread) then
            bullet.Spread = Vector(0, 0, 0)
        end
        if bullet.Dir ~= nil and not isvector(bullet.Dir) then
            bullet.Dir = Vector(0, 0, 1)
        end
        if bullet.Src ~= nil and not isvector(bullet.Src) then
            bullet.Src = self:GetPos()
        end
    end
    return oldFireBullets(self, bullet, ...)
end