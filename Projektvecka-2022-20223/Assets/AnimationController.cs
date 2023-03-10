using UnityEngine;

public class AnimationController : MonoBehaviour
{
    Animator anim;
    TopDownCharacterMover movement;

    Vector3 moveDirection;

    void Awake()
    {
        movement = GetComponent<TopDownCharacterMover>();
        anim = GetComponentInChildren<Animator>();
        anim.applyRootMotion = false;
    }

    void Update()
    {
        //if(transform.forward)
        //    anim.SetFloat
        //var e= Quaternion.Euler(0, Camera.main.transform.rotation.eulerAngles.y, 0) * movement.MoveDir;
        //var e = movement.MoveDir + transform.forward;
        //var e = Quaternion.Euler(0, transform.rotation.eulerAngles.y, 0) * movement.MoveDir;

        //moveDirection = moveDirection.normalized;

        moveDirection = transform.InverseTransformDirection(movement.MoveDir);
        //Debug.Log(moveDirection);
        //moveDirection = Vector3.zero;
        //Debug.Log("ZERO");

        //Debug.Log(moveDirection);
        anim.SetFloat("x", moveDirection.x, .3f, Time.deltaTime);
        anim.SetFloat("y", moveDirection.z, .3f, Time.deltaTime);
    }
}