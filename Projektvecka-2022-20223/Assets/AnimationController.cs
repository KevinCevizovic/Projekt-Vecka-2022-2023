using UnityEngine;

public class AnimationController : MonoBehaviour
{
    Animator anim;
    TopDownCharacterMover movement;

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

        
        anim.SetFloat("x", movement.InputVector.x);
        anim.SetFloat("y", movement.InputVector.y);
    }
}