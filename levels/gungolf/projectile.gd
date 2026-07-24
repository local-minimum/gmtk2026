extends RigidBody3D
class_name Projectile


static var counter: int = 0

@export var decal: PackedScene
@export var collide_decal_layer: int = 10
@export_range(0.0, 2.0) var decal_scale: float = 0.05

var cam: Camera3D
var _has_hit: bool

func _put_decal(state: PhysicsDirectBodyState3D, body: PhysicsBody3D, idx: int) -> void:
    var pt: Vector3 = state.get_contact_collider_position(idx)
    #var norm: Vector3 = linear_velocity.normalized()
    #var norm: Vector3 = _calc_norm(state, body, idx)
    var norm: Vector3 = (pt - cam.global_position).normalized()
    var wound: Node3D = decal.instantiate()
    body.add_child(wound)
    counter += 1
    wound.name = "Bullet Wound %s" % counter
    wound.global_position = pt
    wound.global_basis = Basis(-norm, randf_range(0.0, TAU))
    wound.global_scale(Vector3.ONE * decal_scale)
    _has_hit = true

func _calc_norm(state: PhysicsDirectBodyState3D, _body: Node3D, idx: int) -> Vector3:
    var local_norm: Vector3 = state.get_contact_local_normal(idx)
    #var norm: Vector3 = (body.to_global(local_norm) - body.to_global(Vector3.ZERO)).normalized()
    #if false:
        #if local_norm.y == 0 && local_norm.x == 0:
            #norm = Vector3(local_norm.z, 0, 0)
        #else:
            #norm = Vector3(local_norm.y, -local_norm.x, 0.0)
    return local_norm

func _on_body_shape_entered(_body_rid: RID, body: Node, _body_shape_index: int, _local_shape_index: int) -> void:
    if _has_hit:
        linear_velocity *= 0.7
        return

    var state: PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(get_rid())
    var pb: PhysicsBody3D = _get_body(body)
    if pb:
        for idx in state.get_contact_count():
            var obj: Object = state.get_contact_collider_object(idx)
            if _get_body(obj) == pb:
                if pb.get_collision_layer_value(collide_decal_layer):
                    _put_decal(state, pb, idx)
                    break

    linear_velocity *= 0.7

func _get_body(body: Object) -> PhysicsBody3D:
    if body is Node:
        while body && body is not PhysicsBody3D:
            body = body.get_parent()
    return body
