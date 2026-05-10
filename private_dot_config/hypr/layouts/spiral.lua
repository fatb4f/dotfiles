-- Placeholder spiral layout.
-- Replace with the official example or your own ratio/rotation layout.

hl.layout.register("spiral", {
  recalculate = function(ctx)
    local n = #ctx.targets
    if n == 0 then return end

    for i, target in ipairs(ctx.targets) do
      target:place(ctx:grid_cell(i, math.ceil(math.sqrt(n))))
    end
  end,

  layout_msg = function(ctx, msg)
    -- Add messages later: grow, shrink, rotate, ratio <value>.
  end,
})
